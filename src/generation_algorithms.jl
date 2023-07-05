using Dates
include("utils.jl")

function thresh_distinguishable_colors(map_threshs::Vector{Tuple{ColorDistMap, Float64}}, per_color_duration = Minute(1), refinement_duration = Minute(5))
    colors = [rand_color()]
    map_weights = [(map, 1.0/thresh) for (map, thresh) in map_threshs]
    best_colors = deepcopy(colors)
    prog = ProgressUnknown("Number of iterations:"; dt=1, showspeed=true)
    while refine_colors_thresh!(colors, map_weights, per_color_duration, prog)
        best_colors = deepcopy(colors)
        push!(colors, rand_color())
    end
    refine_colors_local!(best_colors, map_weights, refinement_duration, 300, prog)
    finish!(prog; showvalues=zip(["score[$i]" for i in 1:4],score(best_colors, map_threshs)))
    return sort(best_colors, by = x -> LCHab(x).h)
end

ProgressMeter.next!(::Nothing, args...; kwargs...) = nothing
# If the score is >= 1, or it takes max_its iterations, this function returns.
function refine_colors_thresh!(colors, map_weights, max_duration, prog=ProgressUnknown("Number of iterations:"; dt=1, showspeed=true))
    end_time = now() + max_duration
    scores = get_scores(colors, map_weights)
    (score, indices) = find_min_score(scores)
    while score < 1.0
        if now() >= end_time
            return false
        end
        updated_index = update_index!(colors, map_weights, score, indices)
        update_scores!(scores, updated_index, colors, map_weights)
        (score, indices) = find_min_score(scores)
        next!(prog; showvalues=() -> ((:trying_n, length(colors)), (:score, score), (:time_remaining, canonicalize(end_time - now()))))
    end
    return true
end

function refine_colors!(colors, map_weights, max_duration, prog=ProgressUnknown("Number of iterations:"; dt=1, showspeed=true); init_scores=nothing, num_unlocked=length(colors))
    if (max_duration isa Period)
        end_time = now() + max_duration    
    end
    scores = init_scores
    if isnothing(init_scores)
        scores = get_scores(colors, map_weights, num_unlocked)
    end
    (score, indices) = find_min_score(scores)
    best_score = score
    local_colors = deepcopy(colors)
    n = 0
    while true
        if (max_duration isa Period && now() >= end_time) || (max_duration isa Number && n >= max_duration)
            return
        end
        n += 1
        updated_index = update_index!(local_colors, map_weights, score, indices)
        update_scores!(scores, updated_index, local_colors, map_weights, num_unlocked)
        (score, indices) = find_min_score(scores)
        if score > best_score
            best_score = score
            copy!(colors, local_colors)
        end
        next!(prog; showvalues=() -> ((:score, score), (:best_score, best_score), (:time_remaining, max_duration isa Period ? canonicalize(end_time - now()) : max_duration - n)))
    end
end

function refine_colors_local!(colors, map_weights, max_duration, sub_iters=100, prog=ProgressUnknown("Number of iterations:"; dt=1, showspeed=true); num_unlocked=length(colors))
    end_time = now() + max_duration
    scores = get_scores(colors, map_weights, num_unlocked)
    (best_score, _) = find_min_score(scores)
    while true
        if now() >= end_time
            return
        end
        local_scores = deepcopy(scores)
        refine_colors!(colors, map_weights, sub_iters; init_scores=local_scores, num_unlocked = num_unlocked)
        if local_scores != scores
            scores = get_scores(colors, map_weights, num_unlocked)
            (best_score, _) = find_min_score(scores)
        end
        next!(prog, step=sub_iters; showvalues=() -> ((:score, find_min_score(local_scores)[1]), (:best_score, best_score), (:time_remaining, canonicalize(end_time - now()))))
    end
end

function update_index!(colors, map_weights, score, indices)
    times_to_loop = 100
    if indices[1] == indices[2]
        index_to_update = indices[1]
        c_before_update = colors[index_to_update]
        #=
        new_colors = [nudge_color(c_before_update) for _ in 1:times_to_loop]
        scores = [minimum(weight * dist_map(c) for (dist_map, weight) in map_weights) for c in new_colors]
        i = argmax(scores)
        colors[index_to_update] = new_colors[i]
        # =#
        
        for n in 1:times_to_loop
            colors[index_to_update] = nudge_color(c_before_update)
            if n < times_to_loop
                dist = minimum(weight * dist_map(colors[index_to_update]) for (dist_map, weight) in map_weights)
                if dist > score
                    break 
                end
            end
        end
        # =#
    else
        index_to_update = rand(indices)
        c_before_update = colors[index_to_update]
        c_other = colors[indices[1] == index_to_update ? indices[2] : indices[1]]
        #=
        new_colors = [nudge_color(c_before_update) for _ in 1:times_to_loop]
        scores = [minimum(weight * dist_map.distance(dist_map.f(c_other), dist_map.f(c)) for (dist_map, weight) in map_weights) for c in new_colors]
        i = argmax(scores)
        colors[index_to_update] = new_colors[i]
        # =#
        
        for n in 1:times_to_loop
            colors[index_to_update] = nudge_color(c_before_update)
            if n < times_to_loop
                dist = minimum(weight * dist_map.distance(dist_map.f(c_other), dist_map.f(colors[index_to_update])) for (dist_map, weight) in map_weights)
                if dist > score
                    break
                end
            end
        end
        # =#
    end
    return index_to_update
end

#=
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
# =#