@time begin
    include("discord_colors.jl")
    using BenchmarkTools
end

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
                new_diff_i = i
            end
            scores[i] = (new_diff, new_diff_i)
        end
    end
    if updated_index < length(colors)
        updated_diff, updated_diff_i = findmin(f, colors[updated_index+1:end])
        discord_diff = dist_to_discord_color(c_updated)
        if discord_diff < updated_diff
            updated_diff = discord_diff
            updated_diff_i = updated_index
        end
        scores[updated_index] = (updated_diff, updated_diff_i)
    end
end

rand_color()::RGB{N0f8} = RGB{N0f8}(rand(N0f8), rand(N0f8), rand(N0f8))

#=
begin
    function run_bench()
        colors = [rand_color() for _ in 1:50]
        scores = get_scores(colors)
        @benchmark update_scores!(scores, colors, updated_index) setup = (begin
            colors = $colors
            scores = $scores
            updated_index = rand(eachindex(colors))
            colors[updated_index] = rand_color()
        end)
    end
    run_bench()
end
=#