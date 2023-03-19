using Colors

function get_scores(cols::Vector{<:Color}; seed=nothing)
    all_cols = isnothing(seed) ? cols : vcat(cols, seed)
    n = length(cols)
    m = length(all_cols)
    scores = Vector{Tuple{Float64, Int}}(undef, n)
    scores[n] = (Inf, -1)  # This only stays if there is no seed
    for i in 1:min(m-1, n)
        f(x) = colordiff(x, cols[i])
        diffs = (f.(all_cols[i+1:m]))
        j = argmin(diffs)
        scores[i] = (diffs[j], j + i)
    end
    return scores
end

function get_scores(col_raw::Matrix{<:AbstractFloat}; seed=nothing)
    cols = [RGB(col_raw[i,1], col_raw[i,2], col_raw[i,3]) for i in 1:size(col_raw, 1)]
    return get_scores(cols; seed=seed)
end

function update_scores!(scores::Vector{Tuple{Float64, Int}}, cols::Vector{<:Color}, ind; seed=nothing)
    all_cols = isnothing(seed) ? cols : vcat(cols, seed)
    n = length(cols)
    m = length(all_cols)
    
    f = let c_ind = cols[ind]
        x -> colordiff(x, c_ind)
    end
    for i in 1:ind-1
        if scores[i][2] == ind  # have to recompute all differences sadly

            g = let c_i = cols[i]
                x -> colordiff(x, c_i)
            end
            diffs = g.(all_cols[i+1:m])
            j = argmin(diffs)
            scores[i] = (diffs[j], j + i)
        else
            s = f(cols[i])
            if s < scores[i][1] 
                scores[i] = (s, ind)
            end
        end
    end
    if ind < m
        diffs = f.(all_cols[ind+1:m])
        j = argmin(diffs)
        scores[ind] = (diffs[j], j + ind)
    end

    return scores
end

function update_scores!(scores::Vector{Tuple{Float64, Int}}, col_raw::Matrix{<:AbstractFloat}, ind; seed=nothing)
    cols = [RGB(col_raw[i,1], col_raw[i,2], col_raw[i,3]) for i in 1:size(col_raw, 1)]
    return update_scores!(scores, cols, ind; seed=seed)
end

function evaluate(scores::Vector{Tuple{Float64, Int}}, col_raw::Matrix{T}; seed=nothing) where T<:AbstractFloat
    n = size(col_raw, 1)
    j = argmin(first.(scores))
    k = scores[j][2]
    c_1 = RGB{T}(col_raw[j, 1], col_raw[j, 2], col_raw[j, 3])
    c_2 = k <= n ? RGB{T}(col_raw[k, 1], col_raw[k, 2], col_raw[k, 3]) : seed[k - n]
    return colordiff(c_1, c_2)
end

function evaluate(scores::Vector{Tuple{Float64, Int}}, col_raw::Matrix{<:AbstractFloat}, exact::Val{true}; seed=nothing)
    n = size(col_raw, 1)
    j = argmin(first.(scores))
    k = scores[j][2]
    c_1 = RGB{N0f8}(col_raw[j, 1], col_raw[j, 2], col_raw[j, 3])
    c_2 = k <= n ? RGB{N0f8}(col_raw[k, 1], col_raw[k, 2], col_raw[k, 3]) : RGB{N0f8}(seed[k - n])
    return colordiff(c_1, c_2)
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

function score(col_raw::Matrix{<:AbstractFloat}; seed=nothing)
    cols = [RGB(col_raw[i,1], col_raw[i,2], col_raw[i,3]) for i in 1:size(col_raw, 1)]
    return score(cols, seed)
end

function align(base::AbstractArray{<:T, N}, mixed::AbstractArray{<:T, N}, dist_metric) where {T, N}
    aligned = similar(mixed)
    assigned = falses(size(aligned))
    for c in mixed
        f(x) = dist_metric(x, c)
        diffs = f.(base)
        i = argmin(diffs)
        while assigned[i]
            if diffs[i] < dist_metric(aligned[i], base[i])
                c, aligned[i] = aligned[i], c
                f(x) = dist_metric(x, c)
                diffs = f.(base)
            else
                diffs[i] = maximum(diffs) + 1
            end
            i = argmin(diffs)
        end
        aligned[i] = c
        assigned[i] = true
    end
    return hcat(base, aligned)
end

attempt(n) = score(gd_distinguishable_colors(n)) - score(distinguishable_colors(n))
attempt(n, seed) = align(distinguishable_colors(n, seed; dropseed=true), gd_distinguishable_colors(n, seed), colordiff)