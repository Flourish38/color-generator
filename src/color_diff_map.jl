begin
    using Colors, IterTools, FixedPointNumbers, ProgressMeter, BSON
end

# This function wraps the transform function so that it is guaranteed to use Float64 for computations.
# Converts to Lab because the transform is only intended for use immediately prior to calling colordiff,
# which would convert to Lab anyways.
transform_to_f(transform) = transform == identity ?
    c -> convert(Lab{Float64}, c) :
    c -> convert(Lab{Float64}, transform(convert(typeof(c).name.wrapper{Float64}, c)))

struct ColorDiffMap
    array::Array{Float64, 3}
    transform  # This is a function to be applied TO BOTH COLORS before computing the distance between them. Intended for color vision deficiencies
    ColorDiffMap(transform = identity) = new(fill(Inf64, 256, 256, 256), transform_to_f(transform))
    ColorDiffMap(a::Array{Float64, 3}, transform = identity) = new(a, transform_to_f(transform))
    ColorDiffMap(path::String) = BSON.load(path)[:color_dist_map]
end

Base.Broadcast.broadcastable(map::ColorDiffMap) = Ref(map)

Colors.colordiff(map::ColorDiffMap, color::RGB{N0f8}) = map.array[color.r.i+1, color.g.i+1, color.b.i+1]

const n0f8s = zero(N0f8):eps(N0f8):one(N0f8)

function add_color_simple!(map::ColorDiffMap, color)
    array = map.array
    # colordiff converts to Lab if you don't do it, so I might as well.
    f(c) = map.transform(c)
    color = f(color)
    updates = 0
    for r in n0f8s, g in n0f8s, b in n0f8s
        diff = colordiff(color, f(RGB(r, g, b)))
        if diff < array[r.i+1, g.i+1, b.i+1]
            array[r.i+1, g.i+1, b.i+1] = diff
            updates += 1
        end
    end
    #push!(update_log, updates)
    return updates
end

offsets = (one(N0f8), zero(N0f8), eps(N0f8))
#offsets = (one(N0f8) - eps(N0f8), one(N0f8), zero(N0f8), eps(N0f8), eps(N0f8) + eps(N0f8))  # For if you need 5x5x5 for some reason??

adjacent_colors(color::RGB{N0f8}) = (RGB{N0f8}(color.r + r, color.g + g, color.b + b) for r in offsets, g in offsets, b in offsets if !(r == 0 && g == 0 && b == 0))

function add_color_flood!(map::ColorDiffMap, color)
    array = map.array
    # colordiff converts to Lab if you don't do it, so I might as well.
    f(c) = map.transform(c)
    color = f(color)
    updates = 0
    checked_colors = Set{RGB{N0f8}}()
    colors_to_check = Set{RGB{N0f8}}((convert(RGB{N0f8}, color),))
    while !isempty(colors_to_check)
        c = pop!(colors_to_check)
        push!(checked_colors, c)
        diff = colordiff(f(c), color)
        if diff < array[c.r.i+1, c.g.i+1, c.b.i+1]
            array[c.r.i+1, c.g.i+1, c.b.i+1] = diff
            updates += 1
            if updates >= 838861  # If it updates 5% of the color space, it probably still has a ways to go, and would be better off using a full scan.
                return updates + add_color_simple!(map, color)
            end
            union!(colors_to_check, Iterators.filter(!in(checked_colors), adjacent_colors(c)))
        end
    end
    #push!(update_log, updates)
    return updates
end

rgb(c::Colorant) = red(c), green(c), blue(c)

function add_colors!(map::ColorDiffMap, colors)
    (max_distance, color_index) = first(map.array) != Inf ?
        findmax(colordiff.(map, colors)) :
        (Inf, argmin((c -> sum(abs.(rgb(c) .- (0.5, 0.5, 0.5)))).(colors)))
    p = Progress(length(colors); dt=1)
    consecutive_under_2_percent = 0
    while max_distance > 0
        if consecutive_under_2_percent >= 3
            add_color_flood!(map, colors[color_index])
        elseif add_color_simple!(map, colors[color_index]) <= 335544  # 2% or less of the color space was updated. Should be faster to do a flood fill than a full scan.
            consecutive_under_2_percent += 1
        else
            consecutive_under_2_percent = 0
        end
        (max_distance, color_index) = findmax(colordiff.(map, colors))
        next!(p)
    end
    finish!(p)  # If one or more colors is already computed, the progress meter will not finish
    println()
end

#=
include("discord_colors.jl")
discord_diff_map = ColorDiffMap()
update_log = []
@time add_colors!(discord_diff_map, all_discord_colors)

over_100k_update_data = [16777216,8040674,1039081,1778248,1389735,281900,5374595,741474,1709466,2297019,1821119,1466415,1275960,815312,3647907,321902,3113071,257263,  236383,718127,804093,180944,3139389,604309,323715,156740,3537745,229403,498698,445989,164839,1289816,420898,118579,117794,175323,449186,122930,561343,791263,219529,177418,183523,111786,155057,412529,263394,454489,158216,362151,144908,105908,1111458,1024335,147945,292171,241884,117856,126864,118898,165102,192857,180748,212533,131885,543742,223568,304849,184804,262472,101405,656677]
min = Inf
min_n = 0
min_i = 0
for i in 1:length(update_log)
    total = 419430*(i-1) + sum(update_log[i:end])
    if total < min
        min = total
        min_i = i
        println(i, "\t", total)
    end
end
for n in over_100k_update_data
    total = sum(x -> x > n ? n + 419430 : x, update_log[23:end])
    if total < min
        min = total
        min_n = n
        println(n, "\t", total)
    end
end
=#