include("color_diff_map.jl")
using Random

@views function score(colors::Vector{RGB{N0f8}}, seed::Vector{<:Color}=RGB{N0f8}[]; map::Union{Nothing, ColorDiffMap}=nothing)
    min_diff::Float64 = isnothing(map) ? Inf64 : minimum(colordiff(map, c) for c in colors)
    all_colors = vcat(colors, seed)
    for i in eachindex(colors)
        f = let c = colors[i]
            x -> colordiff(c, x)
        end
        #f(x::RGB{N0f8})::Float64 = colordiff(c, x)  # The let block is actually a smidge faster, kinda cool
        min_diff = minimum(f, all_colors[i+1:end]; init=min_diff)
    end
    return min_diff
end

@views function get_scores(colors::Vector{RGB{N0f8}}, seed::Vector{<:Color}=RGB{N0f8}[]; map::Union{Nothing, ColorDiffMap}=nothing)
    scores = Vector{Tuple{Float64, Int}}(undef, length(colors))
    all_colors = vcat(colors, seed)
    for (i, c) in enumerate(colors)
        min_diff = isnothing(map) ? Inf64 : colordiff(map, c)
        min_diff_index = i
        if i < length(all_colors)
            f(x) = colordiff(x, c)
            diff, j = findmin(f, all_colors[i+1:end])
            if diff < min_diff
                min_diff = diff
                if i + j <= length(colors)  # If the minimum difference is with a seed color, since we can't change that color, we shouldn't point to it.
                    min_diff_index = i + j  # This confirms that the difference is not with a seed color.
                end
            end
        end
        scores[i] = (min_diff, min_diff_index)
    end
    scores
end

@views function update_scores!(scores::Vector{Tuple{Float64, Int}}, updated_index, colors::Vector{RGB{N0f8}}, seed::Vector{<:Color}=RGB{N0f8}[]; map::Union{Nothing, ColorDiffMap}=nothing)
    c_updated = colors[updated_index]
    f(x)::Float64 = colordiff(x, c_updated)
    all_colors = vcat(colors, seed)

    for (i, c) in enumerate(colors[1:updated_index-1])
        prev_diff, prev_diff_i = scores[i]
        diff = f(c)
        if diff < prev_diff
            scores[i] = (diff, updated_index)
        elseif prev_diff_i == updated_index  # Have to recompute minimum for this element
            g(x)::Float64 = colordiff(x, c)
            new_diff, new_diff_i = findmin(g, all_colors[i+1:end])  # This does recompute the difference between the updated color and the recomputing color, sadly.
            new_diff_i += i
            if new_diff_i > length(colors)
                new_diff_i = i
            end
            map_diff = isnothing(map) ? Inf64 : colordiff(map, c)
            if map_diff < new_diff
                new_diff = map_diff
                new_diff_i = i
            end
            scores[i] = (new_diff, new_diff_i)
        end
    end
    updated_diff, updated_diff_i = updated_index < length(all_colors) ? findmin(f, all_colors[updated_index+1:end]) : (Inf, 0)
    updated_diff_i += updated_index
    if updated_diff_i > length(colors)
        updated_diff_i = updated_index
    end
    map_diff = isnothing(map) ? Inf64 : colordiff(map, c)
    if map_diff < updated_diff  # if updated_index == length(colors), this will always be true
        updated_diff = map_diff
        updated_diff_i = updated_index
    end
    scores[updated_index] = (updated_diff, updated_diff_i)
    return
end

@views function find_min_score(scores::Vector{Tuple{Float64, Int}})::Tuple{Float64, Tuple{Int, Int}}
    (min_score, i) = findmin(first, scores)
    return (min_score, (i, scores[i][2]))
end

rand_color()::RGB{N0f8} = RGB{N0f8}(rand(N0f8), rand(N0f8), rand(N0f8))

const nudges = (
    (eps(N0f8), zero(N0f8), zero(N0f8)), # This group is copied 6 times so it makes up the majority of the list
    (one(N0f8), zero(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), zero(N0f8), one(N0f8)),
# = = = =  # You might not want these so here, easy to comment them out
    (eps(N0f8), zero(N0f8), zero(N0f8)),
    (one(N0f8), zero(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), zero(N0f8), one(N0f8)),

    (eps(N0f8), zero(N0f8), zero(N0f8)),
    (one(N0f8), zero(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), zero(N0f8), one(N0f8)),

    (eps(N0f8), zero(N0f8), zero(N0f8)),
    (one(N0f8), zero(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), zero(N0f8), one(N0f8)),

    (eps(N0f8), zero(N0f8), zero(N0f8)),
    (one(N0f8), zero(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), zero(N0f8), one(N0f8)),

    (eps(N0f8), zero(N0f8), zero(N0f8)),
    (one(N0f8), zero(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), zero(N0f8), one(N0f8)),

    (eps(N0f8), eps(N0f8), zero(N0f8)),
    (eps(N0f8), one(N0f8), zero(N0f8)),
    (eps(N0f8), zero(N0f8), eps(N0f8)),
    (eps(N0f8), zero(N0f8), one(N0f8)),

    (one(N0f8), eps(N0f8), zero(N0f8)),
    (one(N0f8), one(N0f8), zero(N0f8)),
    (one(N0f8), zero(N0f8), eps(N0f8)),
    (one(N0f8), zero(N0f8), one(N0f8)),

    (eps(N0f8), eps(N0f8), zero(N0f8)),
    (one(N0f8), eps(N0f8), zero(N0f8)),
    (zero(N0f8), eps(N0f8), eps(N0f8)),
    (zero(N0f8), eps(N0f8), one(N0f8)),

    (eps(N0f8), one(N0f8), zero(N0f8)),
    (one(N0f8), one(N0f8), zero(N0f8)),
    (zero(N0f8), one(N0f8), eps(N0f8)),
    (zero(N0f8), one(N0f8), one(N0f8)),

    (eps(N0f8), zero(N0f8), eps(N0f8)),
    (one(N0f8), zero(N0f8), eps(N0f8)),
    (zero(N0f8), eps(N0f8), eps(N0f8)),
    (zero(N0f8), one(N0f8), eps(N0f8)),

    (eps(N0f8), zero(N0f8), one(N0f8)),
    (one(N0f8), zero(N0f8), one(N0f8)),
    (zero(N0f8), eps(N0f8), one(N0f8)),
    (zero(N0f8), one(N0f8), one(N0f8)),
    
    (eps(N0f8), eps(N0f8), eps(N0f8)),
    (eps(N0f8), eps(N0f8), one(N0f8)),
    (eps(N0f8), one(N0f8), eps(N0f8)),
    (eps(N0f8), one(N0f8), one(N0f8)),
    (one(N0f8), eps(N0f8), eps(N0f8)),
    (one(N0f8), eps(N0f8), one(N0f8)),
    (one(N0f8), one(N0f8), eps(N0f8)),
    (one(N0f8), one(N0f8), one(N0f8)),
# =#
)
nudge_color(x::RGB{N0f8}) = RGB{N0f8}((rgb(x) .+ rand(nudges))...)
#= = = # unused
function nudge_color(x::RGB{N0f8}, offset::Tuple{N0f8, N0f8, N0f8})
    return RGB{N0f8}(x.r + offset[1], x.g + offset[2], x.b + offset[3])
end
=#

#= =
using BenchmarkTools
begin
    function run_bench()
        
        #colors = [rand_color() for _ in 1:50]
        #scores = get_scores(colors)
        #=
        @benchmark update_scores!(scores, colors, updated_index) setup = (begin
            colors = $colors
            scores = $scores
            updated_index = rand(eachindex(colors))
            colors[updated_index] = rand_color()
        end)
        =#
        #@benchmark find_min_score(scores) setup = (scores = $scores)
        @benchmark colordiff(c, d) setup = (c = rand_color(); d = rand_color())
    end
    run_bench()
end
# =#