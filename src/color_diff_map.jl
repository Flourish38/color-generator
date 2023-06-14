begin
    using Colors, IterTools, FixedPointNumbers, ProgressMeter, BSON
end

const ϵ = eps(N0f8)

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
Colors.colordiff(map::ColorDiffMap, color) = colordiff(map, convert(RGB{N0f8}, color))

const n0f8s = zero(N0f8):eps(N0f8):one(N0f8)

function add_color_simple!(map::ColorDiffMap, color)
    array = map.array
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
    return updates, 16777216
end

offsets = (one(N0f8), zero(N0f8), eps(N0f8))
#offsets = (one(N0f8) - eps(N0f8), one(N0f8), zero(N0f8), eps(N0f8), eps(N0f8) + eps(N0f8))  # For if you need 5x5x5 for some reason??

adjacent_colors(color::RGB{N0f8}) = (RGB{N0f8}(color.r + r, color.g + g, color.b + b) for r in offsets, g in offsets, b in offsets if !(r == 0 && g == 0 && b == 0))

function add_color_flood!(map::ColorDiffMap, color, colors_to_check::Set{RGB{N0f8}} = Set((convert(RGB{N0f8}, color),)), checked_colors::Set{RGB{N0f8}} = Set{RGB{N0f8}}())
    array = map.array
    f(c) = map.transform(c)
    color = f(color)
    updates = 0
    while !isempty(colors_to_check)
        c = pop!(colors_to_check)
        push!(checked_colors, c)
        diff = colordiff(f(c), color)
        if diff < array[c.r.i+1, c.g.i+1, c.b.i+1]
            array[c.r.i+1, c.g.i+1, c.b.i+1] = diff
            updates += 1
            if updates >= 838861  # If it updates 5% of the color space, it probably still has a ways to go, and would be better off using a full scan.
                update = add_color_simple!(map, color)
                return updates + update[1], -update[2], 26*updates, length(checked_colors)
            end
            union!(colors_to_check, Iterators.filter(!in(checked_colors), adjacent_colors(c)))
        end
    end
    return updates, length(checked_colors)#, 26*updates
end

function add_color_spiral!(map::ColorDiffMap, color)
    array = map.array
    ic = convert(RGB{N0f8}, color)
    f(c) = map.transform(c)
    color = f(color)
    diff = colordiff(f(ic), color)
    if diff >= array[ic.r.i+1, ic.g.i+1, ic.b.i+1]
        return 0, 0., 1
    end
    array[ic.r.i+1, ic.g.i+1, ic.b.i+1] = diff
    min_r = max_r = ic.r
    min_g = max_g = ic.g
    min_b = max_b = ic.b
    r_d = ic.r != zero(N0f8)
    r_u = ic.r != one(N0f8)
    g_d = ic.g != zero(N0f8)
    g_u = ic.g != one(N0f8)
    b_d = ic.b != zero(N0f8)
    b_u = ic.b != one(N0f8)
    updates = 1
    while true
        ranges = (one(N0f8):zero(N0f8), one(N0f8):zero(N0f8), one(N0f8):zero(N0f8))
        if r_d
            r_d = false
            min_r -= ϵ
            ranges = (min_r:ϵ:min_r, min_g:ϵ:max_g, min_b:ϵ:max_b)
        elseif r_u
            r_u = false
            max_r += ϵ
            ranges = (max_r:ϵ:max_r, min_g:ϵ:max_g, min_b:ϵ:max_b)
        elseif g_d
            g_d = false
            min_g -= ϵ
            ranges = (min_r:ϵ:max_r, min_g:ϵ:min_g, min_b:ϵ:max_b)
        elseif g_u
            g_u = false
            max_g += ϵ
            ranges = (min_r:ϵ:max_r, max_g:ϵ:max_g, min_b:ϵ:max_b)
        elseif b_d
            b_d = false
            min_b -= ϵ
            ranges = (min_r:ϵ:max_r, min_g:ϵ:max_g, min_b:ϵ:min_b)
        elseif b_u
            b_u = false
            max_b += ϵ
            ranges = (min_r:ϵ:max_r, min_g:ϵ:max_g, max_b:ϵ:max_b)
        else
            break
        end
        for r in ranges[1], g in ranges[2], b in ranges[3]
            diff = colordiff(color, f(RGB(r, g, b)))
            if diff < array[r.i+1, g.i+1, b.i+1]
                array[r.i+1, g.i+1, b.i+1] = diff
                updates += 1
                if r == min_r && min_r != zero(N0f8)
                    r_d = true
                end; if r == max_r && max_r != one(N0f8)
                    r_u = true
                end; if g == min_g && min_g != zero(N0f8)
                    g_d = true
                end; if g == max_g && max_g != one(N0f8)
                    g_u = true
                end; if b == min_b && min_b != zero(N0f8)
                    b_d = true
                end; if b == max_b && max_b != one(N0f8)
                    b_u = true
                end
            end
        end
    end
    return updates, (max_r.i+1-min_r.i)*(max_g.i+1-min_g.i)*(max_b.i+1-min_b.i)
end

include("spiral_flood_algorithm.jl")
function add_color_spiral_rec!(map::ColorDiffMap, color)
    ic = convert(RGB{N0f8}, color)
    init_index = (ic.r.i+1, ic.g.i+1, ic.b.i+1)
    color = map.transform(color)
    function f(array, index)
        c = RGB(reinterpret(N0f8, UInt8(index[1] - 1)), reinterpret(N0f8, UInt8(index[2] - 1)), reinterpret(N0f8, UInt8(index[3] - 1)))
        diff = colordiff(map.transform(c), color)
        index = CartesianIndex(index)
        if diff < array[index]
            array[index] = diff
            return true
        end
        return false
    end
    return map_spiral_rec(f, map.array, init_index), -1
end

rgb(c::Colorant) = red(c), green(c), blue(c)

function add_colors!(map::ColorDiffMap, colors)
    (max_distance, color_index) = first(map.array) != Inf ?
        findmax(colordiff.(map, colors)) :
        (Inf, argmin((c -> sum(abs.(rgb(c) .- (0.5, 0.5, 0.5)))).(colors)))
    p = Progress(length(colors); dt=1)
    update_log = []
    for _ in 1:length(colors)
        # spiral is ALWAYS the fastest approach, somehow even faster than simple??
        t = @elapsed result = add_color_spiral!(map, colors[color_index])
        push!(update_log, (color_index, t, result))
        (max_distance, color_index) = findmax(colordiff.(map, colors))
        if max_distance <= 0
            break
        end
        next!(p)
    end
    finish!(p)  # If one or more colors is already computed, the progress meter will not finish
    println()
    return update_log
end

#=
@time begin
    test_map = ColorDiffMap()
    @time @show add_color_simple!(test_map, colorant"red")  # 16777216
    test_map = ColorDiffMap()
    @time @show add_color_spiral!(test_map, colorant"red")  # 16777216
    #=
    @time @show add_color_spiral_rec!(test_map, colorant"lime")  # 6984629
    ##
    @time @show add_color_spiral_rec!(test_map, colorant"blue")  # 6302733
    ##
    @time @show add_color_spiral_rec!(test_map, colorant"magenta")  # 3229852
    @time @show add_color_spiral_rec!(test_map, colorant"cyan")  # 2288623
    @time @show add_color_spiral_rec!(test_map, colorant"yellow")  # 1553871
    @time @show add_color_spiral_rec!(test_map, colorant"black")  # 1217106
    @time @show add_color_spiral_rec!(test_map, colorant"white")  # 962524
    # =#
end
begin 
    @show colordiff(test_map_prewhite, RGB(199/255, 246/255, 1.0))
    @show colordiff(colorant"white", RGB(199/255, 246/255, 1.0))
    @show colordiff(test_map_prewhite, RGB(199/255, 247/255, 1.0))
    @show colordiff(colorant"white", RGB(199/255, 247/255, 1.0))
    @show colordiff(test_map_prewhite, RGB(199/255, 1.0, 1.0))
    @show colordiff(colorant"white", RGB(199/255, 1.0, 1.0))
end

# = =#

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