using Colors, FixedPointNumbers, ProgressMeter

function HyAB(c1::Oklab{T}, c2::Oklab{T})::T where T
    abs(c1.l - c2.l) + sqrt((c1.a - c2.a)^2 + (c1.b - c2.b)^2)
end

n = 20
list = [rand(RGB{N0f8}) for _ in 1:n]

function random_update(c::RGB{N0f8}) 
    i = rand(1:3)
    if i == 1
        return RGB(c.r + rand((one(N0f8), eps(N0f8))), c.g, c.b)
    elseif i == 2
        return RGB(c.r, c.g + rand((one(N0f8), eps(N0f8))), c.b)
    else
        return RGB(c.r, c.g, c.b + rand((one(N0f8), eps(N0f8))))
    end
end

function get_min(list)
    n = length(list)
    newlist = convert.(Oklab{Float32}, list)
    min = (Inf32, (-1, -1))
    for i in 1:n-1
        for j in i+1:n
            s = HyAB(newlist[i], newlist[j])
            if s < min[1]
                min = (s, (i, j))
            end
        end
    end
    update_index = rand(min[2])
    return (update_index, random_update(list[update_index]))
end
function get_min(list, i)
    n = length(list)
    newlist = convert.(Oklab{Float32}, list)
    min = (Inf32, (-1, -1))
    for j in 1:n
        if i == j
            continue
        end
        s = HyAB(newlist[i], newlist[j])
        if s < min[1]
            min = (s, (i, j))
        end
    end
    update_index = rand(min[2])
    return (update_index, random_update(list[update_index]))
end

function test(n, N)
    list = [rand(RGB{N0f8}) for _ in 1:n]
    (i, new_c) = get_min(list)
    @showprogress dt=1 showspeed=true for _ in 1:N
        (i, new_c) = get_min(list, i)
        list[i] = new_c
    end
    list
end

test(20, 100000000)