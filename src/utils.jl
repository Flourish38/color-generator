include("color_dist_map.jl")
using Random
using TravelingSalesmanHeuristics

w_score(colors::Vector{RGB{N0f8}}, map_weights::Vector{Tuple{ColorDistMap, Float64}}) = (x -> x[2]).(map_weights) .* score(colors, map_weights)


@views function score(colors::Vector{RGB{N0f8}}, maps::Vector{ColorDistMap})
    min_dists = [minimum(dist_map.(colors)) for dist_map in maps]
    for (i, dist_map) in enumerate(maps)
        for j in eachindex(colors)
            cd = let c = dist_map.f(colors[j])
                x -> dist_map.distance(c, dist_map.f(x))
            end
            min_dists[i] = minimum(cd, colors[j+1:end]; init = min_dists[i])
        end
    end
    return min_dists
end

function score(colors::Vector{RGB{N0f8}}, map_weights::Vector{Tuple{ColorDistMap, Float64}})
    return score(colors, first.(map_weights))
end

@views function get_scores(colors::Vector{RGB{N0f8}}, map_weights::Vector{Tuple{ColorDistMap, Float64}})
    scores = Vector{Tuple{Float64, Int}}(undef, length(colors))

    for (i, c) in enumerate(colors)
        min_dist = Inf64
        min_dist_index = i
        for (dist_map, weight) in map_weights
            map_dist = weight * dist_map(c)
            if map_dist < min_dist
                min_dist = map_dist
                min_dist_index = i
            end
            fc = dist_map.f(c)
            if i < length(colors)
                cd(x) = weight * dist_map.distance(dist_map.f(x), fc)
                dist, j = findmin(cd, colors[i+1:end])
                if dist < min_dist
                    min_dist = dist
                    min_dist_index = i + j
                end
            end
        end
        scores[i] = (min_dist, min_dist_index)
    end
    scores
end

@views function update_scores!(scores::Vector{Tuple{Float64, Int}}, updated_index, colors::Vector{RGB{N0f8}}, map_weights::Vector{Tuple{ColorDistMap, Float64}})
    recompute = trues(size(colors))
    c_updated = colors[updated_index]
    #u_lock = Threads.SpinLock()
    #score_locks = [Threads.SpinLock() for _ in 1:updated_index - 1]
    # This should run fast enough that multithreading is pointless
    updated_dist = minimum(weight * dist_map(c_updated) for (dist_map, weight) in map_weights)
    updated_dist_i = updated_index
    for (dist_map, weight) in map_weights
        fc_updated = dist_map.f(c_updated)
        cd(c) = weight * dist_map.distance(dist_map.f(c), fc_updated)
        dist, dist_i = updated_index < length(colors) ? findmin(cd, colors[updated_index+1:end]) : (Inf, 0)
        dist_i += updated_index
        #lock(u_lock) do 
            if dist < updated_dist
                updated_dist = dist
                updated_dist_i = dist_i
            end
        #end

        for (i, c) in enumerate(colors[1:updated_index - 1])
            dist = cd(c)
            #lock(score_locks[i]) do 
                prev_dist, _ = scores[i]
                if dist <= prev_dist
                    scores[i] = (dist, updated_index)
                    recompute[i] = false
                end    
            #end
        end
    end
    scores[updated_index] = (updated_dist, updated_dist_i)
    
    # This loop is embarrassingly parallel, yippee!!!
    # have to use eachindex instead of enumerate because @threads doesn't work with generators :/
    #Threads.@threads for i in 1:updated_index - 1
    # Multithreading slower :pensive:
    for (i, c) in enumerate(colors[1:updated_index - 1])
        c = colors[i]
        _, prev_dist_i = scores[i]
        if prev_dist_i == updated_index && recompute[i]
            new_dist = minimum(weight * dist_map(c) for (dist_map, weight) in map_weights)
            new_dist_i = i
            for (dist_map, weight) in map_weights
                fc = dist_map.f(c)
                cd(x) = weight * dist_map.distance(fc, dist_map.f(x))
                dist, dist_i = findmin(cd, colors[i+1:end])  # This does recompute the difference between the updated color and the recomputing color, sadly.
                dist_i += i
                if dist < new_dist
                    new_dist = dist
                    new_dist_i = dist_i
                end
            end
            scores[i] = (new_dist, new_dist_i)
        end
    end
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

function maybe_nudge_colors(colors::Vector{RGB{N0f8}}, indices, frac=rand())
    new_colors = similar(colors)
    for (i, c) in enumerate(colors) 
        if i in indices || rand() <= frac
            new_colors[i] = nudge_color(c)
        else
            new_colors[i] = c
        end
    end
    return new_colors
end

function tsp_order(colors, diff_map::Union{Nothing, ColorDistMap})
    f = get_f(diff_map)
    D = [colordiff(f(c1), f(c2)) for c1 in colors, c2 in colors]
    path, cost = simulated_annealing(D)
    path, cost = two_opt(D, path)
    return colors[path[1:length(colors)]]
end

Base.transpose(x::Colorant) = x
function display_colors(colors, dist_maps::Vector{ColorDistMap})
    println("score: \t", score(colors, dist_maps))
    println(collect(map(x -> "#" * hex(x), colors)))
    display_cols = colors
    for dist_map in dist_maps
        if dist_map.f == default_f || dist_map.f == identity
            continue
        end
        display_cols = hcat(display_cols, fill(HSL(223, 0.067, 0.206), length(colors)), dist_map.f.(colors))
    end
    display(transpose(display_cols))
    nothing
end
function display_colors(colors, dist_maps::Vector{Tuple{ColorDistMap, Float64}})
    println("weighted score: \t", w_score(colors, dist_maps))
    display_colors(colors, first.(dist_maps))
end

map_threshs_to_weights(map_threshs) = [(dist_map, 1.0/thresh) for (dist_map, thresh) in map_threshs]

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