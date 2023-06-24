begin
    using Colors, IterTools, FixedPointNumbers, ProgressMeter, BSON
end

const ϵ = eps(N0f8)

default_f(c) = convert(LCHab{Float64}, c)
# This function wraps the transform function so that it is guaranteed to use Float64 for computations.
# Converts to Lab because the transform is only intended for use immediately prior to calling colordiff,
# which would convert to Lab anyways.
lab(f) = c -> f(convert(Lab{Float64}, c))

struct ColorDistMap
    array::Array{Float64, 3}
    f  # The function used to transform the color BEFORE computing the distance.
    distance  # The function used to compute the distance between colors.
    ColorDistMap(f = default_f, distance = colordiff) = new(fill(Inf64, 256, 256, 256), f, distance)
    ColorDistMap(a::Array{Float64, 3}, f = default_f, distance = colordiff) = new(a, f, distance)
    ColorDistMap(path::String) = BSON.load(path)[:color_dist_map]
end

Base.Broadcast.broadcastable(map::ColorDistMap) = Ref(map)

(dist_map::ColorDistMap)(color::RGB{N0f8}) = dist_map.array[color.r.i+1, color.g.i+1, color.b.i+1]
(dist_map::ColorDistMap)(color) = dist_map(convert(RGB{N0f8}, color))

get_f(dist_map::ColorDistMap) = dist_map.f

const n0f8s = zero(N0f8):eps(N0f8):one(N0f8)

function add_color_simple!(dist_map::ColorDistMap, color)
    array = dist_map.array
    color = dist_map.f(color)
    updates = 0
    for r in n0f8s, g in n0f8s, b in n0f8s
        dist = dist_map.distance(color, dist_map.f(RGB(r, g, b)))
        if dist < array[r.i+1, g.i+1, b.i+1]
            array[r.i+1, g.i+1, b.i+1] = dist
            updates += 1
        end
    end
    return updates, 16777216
end

offsets = (one(N0f8), zero(N0f8), eps(N0f8))
#offsets = (one(N0f8) - eps(N0f8), one(N0f8), zero(N0f8), eps(N0f8), eps(N0f8) + eps(N0f8))  # For if you need 5x5x5 for some reason??

adjacent_colors(color::RGB{N0f8}) = (RGB{N0f8}(color.r + r, color.g + g, color.b + b) for r in offsets, g in offsets, b in offsets if !(r == 0 && g == 0 && b == 0))

function add_color_flood!(dist_map::ColorDistMap, color, colors_to_check::Set{RGB{N0f8}} = Set((convert(RGB{N0f8}, color),)), checked_colors::Set{RGB{N0f8}} = Set{RGB{N0f8}}())
    array = dist_map.array
    color = dist_map.f(color)
    updates = 0
    while !isempty(colors_to_check)
        c = pop!(colors_to_check)
        push!(checked_colors, c)
        dist = dist_map.distance(dist_map.f(c), color)
        if dist < array[c.r.i+1, c.g.i+1, c.b.i+1]
            array[c.r.i+1, c.g.i+1, c.b.i+1] = dist
            updates += 1
            #=
            if updates >= 838861  # If it updates 5% of the color space, it probably still has a ways to go, and would be better off using a full scan.
                update = add_color_simple!(map, color)
                return updates + update[1], -update[2], 26*updates, length(checked_colors)
            end
            =#
            union!(colors_to_check, Iterators.filter(!in(checked_colors), adjacent_colors(c)))
        end
    end
    return updates, length(checked_colors)#, 26*updates
end

function add_color_spiral!(dist_map::ColorDistMap, color)
    array = dist_map.array
    ic = convert(RGB{N0f8}, color)
    color = dist_map.f(color)
    dist = dist_map.distance(dist_map.f(ic), color)
    if dist >= array[ic.r.i+1, ic.g.i+1, ic.b.i+1]
        return 0, 0., 1
    end
    array[ic.r.i+1, ic.g.i+1, ic.b.i+1] = dist
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
            dist = dist_map.distance(color, dist_map.f(RGB(r, g, b)))
            if dist < array[r.i+1, g.i+1, b.i+1]
                array[r.i+1, g.i+1, b.i+1] = dist
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
function add_color_spiral_rec!(dist_map::ColorDistMap, color)
    ic = convert(RGB{N0f8}, color)
    init_index = (ic.r.i+1, ic.g.i+1, ic.b.i+1)
    color = dist_map.f(color)
    function f(array, index)
        c = RGB(reinterpret(N0f8, UInt8(index[1] - 1)), reinterpret(N0f8, UInt8(index[2] - 1)), reinterpret(N0f8, UInt8(index[3] - 1)))
        dist = dist_map.distance(dist_map.f(c), color)
        index = CartesianIndex(index)
        if dist < array[index]
            array[index] = dist
            return true
        end
        return false
    end
    return map_spiral_rec(f, dist_map.array, init_index), -1
end

rgb(c::Colorant) = red(c), green(c), blue(c)

function add_colors!(map::ColorDistMap, colors)
    (max_distance, color_index) = first(map.array) != Inf ?
        findmax(map.(colors)) :
        (Inf, argmin((c -> sum(abs.(rgb(c) .- (0.5, 0.5, 0.5)))).(colors)))
    p = Progress(length(colors); dt=1)
    update_log = []
    for _ in 1:length(colors)
        # spiral is ALWAYS the fastest approach, somehow even faster than simple??
        t = @elapsed result = add_color_spiral!(map, colors[color_index])
        push!(update_log, (color_index, t, result))
        (max_distance, color_index) = findmax(map.(colors))
        if max_distance <= 0
            break
        end
        next!(p)
    end
    finish!(p)  # If one or more colors is already computed, the progress meter will not finish
    println()
    return update_log
end

function save(map::ColorDistMap, path::String)
    bson(path; color_dist_map = map)
end
