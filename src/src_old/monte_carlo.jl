begin
    using Colors, ForwardDiff, DataStructures, FixedPointNumbers
    using BenchmarkTools, ProgressMeter
    include("utils.jl")
end


function mc_distinguishable_colors(n, seed=nothing; its=-1, thresh=-1)
    ϵ = 1e-9
    isnothing(seed) || (seed = RGB{Float64}.([clamp.(f.(RGB{N0f8}.(seed)), ϵ, 1) for f in (red, green, blue)]...))
    #start = distinguishable_colors(n, isnothing(seed) ? RGB{Float64}[] : seed; dropseed=true)
    #vars = Matrix{Float64}(undef, n, 3)
    #=
    for i in 1:n
        vars[i,1] = red(start[i])
        vars[i,2] = green(start[i])
        vars[i,3] = blue(start[i])
    end
    =#
    vars = rand(0.0:eps(N0f8):1.001, n, 3)
    vars = clamp.(vars, ϵ, 1)

    scores = get_scores(vars; seed=seed)

    best_score = s = evaluate(scores, vars, Val(true); seed=seed)
    best = deepcopy(vars)
    p = ProgressUnknown("Best Score:"; dt=1, showspeed=true)
    it = 0
    last_improvement = 0
    while true
        if it > its && (it - last_improvement) > thresh
            break
        end
        it += 1
        grad = ForwardDiff.gradient(x -> evaluate(scores, x; seed=seed), vars)
        i = rand(CartesianIndices(vars)[grad .!= 0.0])
        vars[i] += sign(grad[i]) * eps(N0f8)
        vars[i] = clamp(vars[i], ϵ, 1)
        update_scores!(scores, vars, i[1]; seed=seed)
        s = evaluate(scores, vars, Val(true); seed=seed)
        if s > best_score && score(vars; seed=seed) > best_score  # Stupid bug. Shouldn't need to calculate full score. Doesn't really impact performance though so /shrug
            best = deepcopy(vars)
            best_score = score(vars; seed=seed)
            last_improvement = it
        end
        ProgressMeter.next!(p; showvalues = ((:score, best_score), (:improved, last_improvement)))
    end
    return sort([RGB{N0f8}(best[i, 1], best[i, 2], best[i, 3]) for i in 1:n], by = x -> LCHab(x).h)
end