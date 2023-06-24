include("color_diff_map.jl")
using Random
using TravelingSalesmanHeuristics

Colors.colordiff(::Nothing, _) = Inf64
get_f(map::Nothing) = identity_f

@views function score(colors::Vector{RGB{N0f8}}, seed::Vector{<:Color}=RGB{N0f8}[]; map::Union{Nothing, ColorDiffMap}=nothing)
    min_diff::Float64 = minimum(colordiff(map, c) for c in colors)
    f = get_f(map)
    all_colors = vcat(colors, seed)
    for i in eachindex(colors)
        cd = let c = colors[i]
            x -> colordiff(f(c), f(x))
        end
        #f(x::RGB{N0f8})::Float64 = colordiff(c, x)  # The let block is actually a smidge faster, kinda cool
        min_diff = minimum(cd, all_colors[i+1:end]; init=min_diff)
    end
    return min_diff
end

@views function get_scores(colors::Vector{RGB{N0f8}}, seed::Vector{<:Color}=RGB{N0f8}[]; map::Union{Nothing, ColorDiffMap}=nothing)
    scores = Vector{Tuple{Float64, Int}}(undef, length(colors))
    f = get_f(map)
    all_colors = vcat(colors, seed)
    for (i, c) in enumerate(colors)
        min_diff = colordiff(map, c)
        min_diff_index = i
        if i < length(all_colors)
            cd(x) = colordiff(f(x), f(c))
            diff, j = findmin(cd, all_colors[i+1:end])
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
    f = get_f(map)
    cd(x)::Float64 = colordiff(f(x), f(c_updated))
    all_colors = vcat(colors, seed)

    for (i, c) in enumerate(colors[1:updated_index-1])
        prev_diff, prev_diff_i = scores[i]
        diff = cd(c)
        if diff < prev_diff
            scores[i] = (diff, updated_index)
        elseif prev_diff_i == updated_index  # Have to recompute minimum for this element
            cd_sub(x)::Float64 = colordiff(f(x), f(c))
            new_diff, new_diff_i = findmin(cd_sub, all_colors[i+1:end])  # This does recompute the difference between the updated color and the recomputing color, sadly.
            new_diff_i += i
            if new_diff_i > length(colors)
                new_diff_i = i
            end
            map_diff = colordiff(map, c)
            if map_diff < new_diff
                new_diff = map_diff
                new_diff_i = i
            end
            scores[i] = (new_diff, new_diff_i)
        end
    end
    updated_diff, updated_diff_i = updated_index < length(all_colors) ? findmin(cd, all_colors[updated_index+1:end]) : (Inf, 0)
    updated_diff_i += updated_index
    if updated_diff_i > length(colors)
        updated_diff_i = updated_index
    end
    map_diff = colordiff(map, c_updated)
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

function tsp_order(colors, diff_map::Union{Nothing, ColorDiffMap})
    f = get_f(diff_map)
    D = [colordiff(f(c1), f(c2)) for c1 in colors, c2 in colors]
    path, cost = simulated_annealing(D)
    path, cost = two_opt(D, path)
    return colors[path[1:length(colors)]]
end

Base.transpose(x::Colorant) = x
function display_colors(colors, diff_map)
    println(collect(map(x -> "#" * hex(x), colors)))
    if diff_map.transform == identity_f
        display_cols = hcat(colors, fill(colorant"black", length(colors)))
        display_cols = hcat(display_cols, tsp_order(colors, diff_map))
        display(transpose(display_cols))
    else
        display_cols = hcat(colors, fill(colorant"black", length(colors)), diff_map.transform.(colors), fill(colorant"black", length(colors), 2))
        tsp_colors = tsp_order(colors, diff_map)
        display_cols = hcat(display_cols, tsp_colors, fill(colorant"black", length(colors)), diff_map.transform.(tsp_colors))
        display(transpose(display_cols))
    end
    nothing
end


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