include("discord_colors.jl")
using Random

function min_dist_to_discord_color(colors::Vector{RGB{N0f8}})::Float64
    return minimum(dist_to_discord_color, colors)
end

@views function score(colors::Vector{RGB{N0f8}})
    min_diff::Float64 = min_dist_to_discord_color(colors)
    for i in eachindex(colors)
        f = let c = colors[i]
            x::RGB{N0f8}-> colordiff(c, x)
        end
        #f(x::RGB{N0f8})::Float64 = colordiff(c, x)  # The let block is actually a smidge faster, kinda cool
        min_diff = minimum(f, colors[i+1:end]; init=min_diff)
    end
    return min_diff
end

@views function get_scores(colors::Vector{<:Color})
    scores = Vector{Tuple{Float64, Int}}(undef, length(colors))
    for (i, c) in enumerate(colors)
        min_diff = dist_to_discord_color(c)
        min_diff_index = i
        if i < length(colors)
            f(x) = colordiff(x, c)
            diff, j = findmin(f, colors[i+1:length(colors)])
            if diff < min_diff
                min_diff = diff
                min_diff_index = j + i
            end
        end
        scores[i] = (min_diff, min_diff_index)
    end
    scores
end

@views function update_scores!(scores::Vector{Tuple{Float64, Int}}, colors::Vector{RGB{N0f8}}, updated_index)
    c_updated = colors[updated_index]
    f(x::RGB{N0f8})::Float64 = colordiff(x, c_updated)

    for (i, c) in enumerate(colors[1:updated_index-1])
        prev_diff, prev_diff_i = scores[i]
        diff = f(c)
        if diff < prev_diff
            scores[i] = (diff, updated_index)
        elseif prev_diff_i == updated_index  # Have to recompute minimum for this element
            g(x::RGB{N0f8})::Float64 = colordiff(x, c)
            new_diff, new_diff_i = findmin(g, colors[i+1:end])  # This does recompute the difference between the updated color and the recomputing color, sadly.
            discord_diff = dist_to_discord_color(c)
            if discord_diff < new_diff
                new_diff = discord_diff
                new_diff_i = 0  # since we add i later anyways, this is correct
            end
            scores[i] = (new_diff, new_diff_i + i)
        end
    end
    updated_diff, updated_diff_i = updated_index < length(colors) ? findmin(f, colors[updated_index+1:end]) : (Inf, 0)
    discord_diff = dist_to_discord_color(c_updated)
    if discord_diff < updated_diff  # if updated_index == length(colors), this will always be true
        updated_diff = discord_diff
        updated_diff_i = 0  # since we add updated_index later anyways, this is correct
    end
    scores[updated_index] = (updated_diff, updated_diff_i + updated_index)
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