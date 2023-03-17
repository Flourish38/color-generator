@time begin
    using Colors, ForwardDiff, DataStructures, FixedPointNumbers
    using BenchmarkTools, ProgressMeter
    include("utils.jl")
end

function score(cols::Array{<:Color}, seed=nothing)
    all_cols = isnothing(seed) ? cols : vcat(cols, seed)
    score = -1.0
    for c in cols
        f(x) = colordiff(x, c)
        if score == -1.0
            score = minimum(f.(filter(x -> x != c, all_cols)))
        else
            score = min(score, minimum(f.(filter(x -> x != c, all_cols))))
        end
    end
    return score
end

function evaluate(col_raw::Array{T,2}, seed=nothing) where T
    cols = [RGB{T}(col_raw[i,1], col_raw[i,2], col_raw[i,3]) for i in 1:size(col_raw, 1)]
    return score(cols, seed)
end

function gd_distinguishable_colors(n, seed=nothing)
    ϵ = 1e-9
    isnothing(seed) || (seed = RGB{Float64}.([clamp.(f.(seed), ϵ, 1) for f in (red, green, blue)]...))
    start = distinguishable_colors(n, isnothing(seed) ? RGB{Float64}[] : seed; dropseed=true)
    vars = Matrix{Float64}(undef, n, 3)
    for i in 1:n
        vars[i,1] = red(start[i])
        vars[i,2] = green(start[i])
        vars[i,3] = blue(start[i])
    end
    vars = clamp.(vars, ϵ, 1)

    past = CircularBuffer{Float64}(10)
    push!(past, 0.)
    s = evaluate(vars, seed)
    while !(s in past) || s != maximum(past)
        push!(past, s)
        grad = ForwardDiff.gradient(x -> evaluate(x, seed), vars)
        i = grad .!= 0.0
        vars[i] .+= sign.(grad[i]) .* eps(N0f8)
        vars[i] = clamp.(vars[i], ϵ, 1)
        s = evaluate(vars, seed)
    end
    return [RGB(vars[i, 1], vars[i, 2], vars[i, 3]) for i in 1:n]
end

function mc_distinguishable_colors(n, seed=nothing; its=-1, thresh=-1)
    ϵ = 1e-9
    isnothing(seed) || (seed = RGB{Float64}.([clamp.(f.(seed), ϵ, 1) for f in (red, green, blue)]...))
    start = distinguishable_colors(n, isnothing(seed) ? RGB{Float64}[] : seed; dropseed=true)
    vars = Matrix{Float64}(undef, n, 3)
    #=
    for i in 1:n
        vars[i,1] = red(start[i])
        vars[i,2] = green(start[i])
        vars[i,3] = blue(start[i])
    end
    =#
    vars = rand(0.0:eps(N0f8):1.0, n, 3)
    vars = clamp.(vars, ϵ, 1)

    best_score = s = evaluate(vars, seed)
    best = Matrix{Float64}(undef, n, 3)
    p = ProgressUnknown("Best Score:"; dt=1, showspeed=true)
    it = 0
    last_improvement = 0
    while true
        if it > its && (it - last_improvement) > thresh
            break
        end
        it += 1
        grad = ForwardDiff.gradient(x -> evaluate(x, seed), vars)
        i = rand(CartesianIndices(vars)[grad .!= 0.0])
        vars[i] += sign(grad[i]) * eps(N0f8)
        vars[i] = clamp(vars[i], ϵ, 1)
        s = evaluate(vars, seed)
        if s > best_score
            best = deepcopy(vars)
            best_score = s
            last_improvement = it
        end
        ProgressMeter.next!(p; showvalues = [(:score, best_score), (:improved, last_improvement)])
    end
    return [RGB(best[i, 1], best[i, 2], best[i, 3]) for i in 1:n]
end

function gd_distinguishable_colors_it(n; samples=0)
    start = distinguishable_colors(n)
    baseline = score(start)
    tries = 0
    best_score = 0
    best = fill(0., n, 3)
    prog = samples == 0 ? ProgressThresh(0.0; showspeed=true) : Progress(samples; showspeed=true)
    
    while samples == 0 ? best_score < baseline : tries < samples
        vars = rand(0.0:eps(N0f8):1.0, n, 3)
        past = CircularBuffer{Float64}(5)
        push!(past, 0.)
        s = evaluate(vars)
        while !(s in past) || s != maximum(past)
            push!(past, s)
            grad = ForwardDiff.gradient(x -> evaluate(x), vars)
            vars .+= sign.(grad) .* eps(N0f8)
            s = evaluate(vars)
        end
        if s > best_score
            best_score = s
            best = vars
        end
        tries += 1
        ProgressMeter.update!(prog, samples == 0 ? baseline - best_score : tries)
    end

    return best_score < baseline ? start : [RGB(best[i, 1], best[i, 2], best[i, 3]) for i in 1:n]
end

begin
    n = 10
    start = distinguishable_colors(n)
    vars = rand(0.0:eps(N0f8):1.0, n, 3)
    for i in 2:n
        vars[i,1] = red(start[i])
        vars[i,2] = green(start[i])
        vars[i,3] = blue(start[i])
    end
    past = CircularBuffer{Float64}(10)
    push!(past, 0.)
    s = @show evaluate(vars)
    @time while !(s in past) || s != maximum(past)
        push!(past, s)
        grad = ForwardDiff.gradient(x -> evaluate(x), vars)
        vars .+= sign.(grad) .* eps(N0f8)
        s = @show evaluate(vars)
    end
end

nothing