include("utils.jl")

function so_distinguishable_colors(n::Int, seed::Vector{<:Color}=RGB{N0f8}[]; its=-1, thresh=-1, map::Union{Nothing, ColorDiffMap}=nothing)
    colors = [rand_color() for _ in 1:n]
    scores = get_scores(colors, seed; map=map)
    f = get_f(map)
    (score, indices) = find_min_score(scores)
    best_score = score
    best_colors = deepcopy(colors)
    last_improvement = num_iters = 0
    prog = ProgressUnknown("Number of iterations:"; dt=1, showspeed=true)
    while num_iters < its || num_iters - last_improvement < thresh
        num_iters += 1
        if indices[1] == indices[2]
            index_to_update = indices[1]
            c_before_update = colors[index_to_update]
            c_updated = nudge_color(c_before_update)
            diff = minimum(colordiff(f(c_updated), f(c)) for c in seed; init=colordiff(map, c_updated))
            if diff < score
                c_updated_alt = nudge_color(c_before_update)
                if minimum(colordiff(f(c_updated_alt), f(c)) for c in seed; init=colordiff(map, c_updated_alt)) > diff
                    c_updated = c_updated_alt
                end
            end
            colors[index_to_update] = c_updated
        else
            index_to_update = rand(indices)
            c_before_update = colors[index_to_update]
            c_other = colors[indices[1] == index_to_update ? indices[2] : indices[1]]
            c_updated = nudge_color(c_before_update)
            diff = colordiff(f(c_updated), f(c_other))
            if diff < score
                c_updated_alt = nudge_color(c_before_update)
                if colordiff(f(c_updated_alt), f(c_other)) > diff
                    c_updated = c_updated_alt
                end
            end
            colors[index_to_update] = c_updated
        end
        update_scores!(scores, index_to_update, colors, seed; map=map)
        (score, indices) = find_min_score(scores)
        if score > best_score
            last_improvement = num_iters
            best_score = score
            copy!(best_colors, colors)
        end
        next!(prog; showvalues = ((:score, score), (:best_score, best_score), (:last_improvement, last_improvement)))
    end
    finish!(prog; showvalues = ((:score, score), (:best_score, best_score), (:last_improvement, last_improvement)))
    return sort(best_colors, by = x -> LCHab(x).h)
end