using StaticArrays
# Sadly, this algorithm is unused...
# I think I made it too generic for it to be fast by making it work in an arbitrary number of dimensions
# BUT, I'm still really proud of it, and I might end up using it again in the future :P

struct SpiralFloodExtent{N}
    min_surface_min_extents::MMatrix{N, N, Int}
    min_surface_max_extents::MMatrix{N, N, Int}
    max_surface_min_extents::MMatrix{N, N, Int}
    max_surface_max_extents::MMatrix{N, N, Int}
    function SpiralFloodExtent(::Val{N}) where N
        new{N}((@MMatrix fill(typemax(Int), N, N)), (@MMatrix fill(0, N, N)), (@MMatrix fill(typemax(Int), N, N)), (@MMatrix fill(0, N, N)))
    end
end

map_spiral_rec(f, array::T, index::CartesianIndex{N}, branch_factor = prevfloat(1/(3^(N-1)))) where {N, T<:AbstractArray{<:Any, N}} = map_spiral_rec(f, array, Tuple(index), branch_factor)
function map_spiral_rec(f, array::T, index::NTuple{N}, branch_factor = prevfloat(1/(3^(N-1)))) where {N, T<:AbstractArray{<:Any, N}}
    ax = axes(array)
    if f(array, index)
        extent = SpiralFloodExtent(Val(N))
        for d in 1:N
            if index[d] > minimum(ax[d])
                extent.min_surface_min_extents[d, :] .= index
                extent.min_surface_max_extents[d, :] .= index
            else
                extent.min_surface_min_extents[d, :] .= maximum(ax[d]) .+ 1
                extent.min_surface_max_extents[d, :] .= minimum(ax[d]) .+ 1
                extent.min_surface_min_extents[d, d] = extent.min_surface_max_extents[d, d] = index[d]
            end
            if index[d] < maximum(ax[d])
                extent.max_surface_min_extents[d, :] .= index
                extent.max_surface_max_extents[d, :] .= index
            else
                extent.max_surface_min_extents[d, :] .= maximum(ax[d]) .+ 1
                extent.max_surface_max_extents[d, :] .= minimum(ax[d]) .+ 1
                extent.max_surface_min_extents[d, d] = extent.max_surface_max_extents[d, d] = index[d]
            end
        end
        return 1 + map_spiral_rec(f, array, extent, branch_factor)
    end
    return 0
end

function map_spiral_rec(f, array::T, extent::SpiralFloodExtent{N}, branch_factor = prevfloat(1/(3^(N-1)))) where {N, T<:AbstractArray{<:Any, N}}
    f_trues = 0
    ax = axes(array)
    ranges = (1:0 for _ in 1:N)
    while true
        for i = 1:N
            max_size_to_branch = branch_factor * prod((extent.max_surface_max_extents[j, j] + 1 - extent.min_surface_min_extents[j, j] for j in 1:N if j != i), init = 1)
            extent_min_subsurface_size = prod((max(0, extent.min_surface_max_extents[i, j] + 1 - extent.min_surface_min_extents[i, j]) for j in 1:N if j != i), init = 1)
            if extent_min_subsurface_size >= max_size_to_branch
                surface_position = extent.min_surface_min_extents[i, i]  # hold on to the surface position so it doesn't get lost
                extent.min_surface_min_extents[i, :] .= maximum.(ax) .+ 1  # reset these since there are no confirmed values yet
                extent.min_surface_max_extents[i, :] .= minimum.(ax) .- 1
                if surface_position == minimum(ax[i])  # Uh oh, we have reached the edge!! don't wanna expand that way any more!!!
                    extent.min_surface_min_extents[i, i] = extent.min_surface_max_extents[i, i] = surface_position
                else
                    surface_position -= 1  # move minimum surface down by 1
                    extent.min_surface_min_extents[i, i] = extent.min_surface_max_extents[i, i] = surface_position
                    ranges = (j == i ? (surface_position:surface_position) : (extent.min_surface_min_extents[j, j]:extent.max_surface_max_extents[j, j]) for j in 1:N)  # The surface to iterate over this iteration
                    break
                end
            end
            extent_max_subsurface_size = prod((max(0, extent.max_surface_max_extents[i, j] + 1 - extent.max_surface_min_extents[i, j]) for j in 1:N if j != i), init = 1)
            if extent_max_subsurface_size >= max_size_to_branch
                surface_position = extent.max_surface_max_extents[i, i]  # hold on to the surface position so it doesn't get lost
                extent.max_surface_min_extents[i, :] .= maximum.(ax) .+ 1  # reset these since there are no confirmed values yet
                extent.max_surface_max_extents[i, :] .= minimum.(ax) .- 1
                if surface_position == maximum(ax[i])  # Uh oh, we have reached the edge!! don't wanna expand that way any more!!!
                    extent.max_surface_min_extents[i, i] = extent.max_surface_max_extents[i, i] = surface_position
                else
                    surface_position += 1  # move maximum surface up by 1
                    extent.max_surface_min_extents[i, i] = extent.max_surface_max_extents[i, i] = surface_position  # make sure we don't lose the surface
                    ranges = (j == i ? (surface_position:surface_position) : (extent.min_surface_min_extents[j, j]:extent.max_surface_max_extents[j, j]) for j in 1:N)  # The surface to iterate over this iteration
                    break
                end
            end
            if i == N  # No surfaces left to expand, so we're done!
                for i in 1:N
                    if all(>(0), extent.min_surface_max_extents[i, j] + 1 - extent.min_surface_min_extents[i, j] for j in 1:N if j != i)
                        # construct a new extent to pass into the algorithm recursively
                        sub_extent = SpiralFloodExtent(Val(N))
                        for d in 1:N
                            sub_extent.min_surface_min_extents[d, :] .= sub_extent.max_surface_min_extents[d, :] .= maximum.(ax) .+ 1
                            sub_extent.min_surface_max_extents[d, :] .= sub_extent.max_surface_max_extents[d, :] .= minimum.(ax) .- 1
                            sub_extent.min_surface_min_extents[d, d] = sub_extent.min_surface_max_extents[d, d] = extent.min_surface_min_extents[i, d]
                            sub_extent.max_surface_min_extents[d, d] = sub_extent.max_surface_max_extents[d, d] = extent.min_surface_max_extents[i, d]
                        end
                        sub_extent.min_surface_min_extents[i, :] .= extent.min_surface_min_extents[i, :]
                        sub_extent.min_surface_max_extents[i, :] .= extent.min_surface_max_extents[i, :]
                        #=
                        println("branch min\t", i, 
                            "\t", prod((max(0, extent.min_surface_max_extents[i, j] + 1 - extent.min_surface_min_extents[i, j]) for j in 1:N if j != i), init = 1), 
                            "\t", prod((extent.max_surface_max_extents[j, j] + 1 - extent.min_surface_min_extents[j, j] for j in 1:N if j != i), init = 1))
                        =#
                        f_trues += map_spiral_rec(f, array, sub_extent, branch_factor)
                        # No need to clear the surface since we no longer use it!
                    end
                    if all(>(0), extent.max_surface_max_extents[i, j] + 1 - extent.max_surface_min_extents[i, j] for j in 1:N if j != i)
                        # construct a new extent to pass into the algorithm recursively
                        sub_extent = SpiralFloodExtent(Val(N))
                        for d in 1:N
                            sub_extent.min_surface_min_extents[d, :] .= sub_extent.max_surface_min_extents[d, :] .= maximum.(ax) .+ 1
                            sub_extent.min_surface_max_extents[d, :] .= sub_extent.max_surface_max_extents[d, :] .= minimum.(ax) .- 1
                            sub_extent.min_surface_min_extents[d, d] = sub_extent.min_surface_max_extents[d, d] = extent.max_surface_min_extents[i, d]
                            sub_extent.max_surface_min_extents[d, d] = sub_extent.max_surface_max_extents[d, d] = extent.max_surface_max_extents[i, d]
                        end
                        sub_extent.max_surface_min_extents[i, :] .= extent.max_surface_min_extents[i, :]
                        sub_extent.max_surface_max_extents[i, :] .= extent.max_surface_max_extents[i, :]
                        #=
                        println("branch max\t", i, 
                            "\t", prod((max(0, extent.max_surface_max_extents[i, j] + 1 - extent.max_surface_min_extents[i, j]) for j in 1:N if j != i), init = 1), 
                            "\t", prod((extent.max_surface_max_extents[j, j] + 1 - extent.min_surface_min_extents[j, j] for j in 1:N if j != i), init = 1))
                        =#
                        f_trues += map_spiral_rec(f, array, sub_extent, branch_factor)
                        # No need to clear the surface since we no longer use it!
                    end
                end
                return f_trues
            end
        end
        for i in Iterators.product(ranges...)
            if f(array, i)
                f_trues += 1
                for d in 1:N
                    if extent.min_surface_min_extents[d, d] == i[d] && i[d] > minimum(ax[d])
                        extent.min_surface_min_extents[d, :] .= min.(extent.min_surface_min_extents[d, :], i)
                        extent.min_surface_max_extents[d, :] .= max.(extent.min_surface_max_extents[d, :], i)
                    end
                    if extent.max_surface_max_extents[d, d] == i[d] && i[d] < maximum(ax[d])
                        extent.max_surface_min_extents[d, :] .= min.(extent.max_surface_min_extents[d, :], i)
                        extent.max_surface_max_extents[d, :] .= max.(extent.max_surface_max_extents[d, :], i)
                    end
                end
            end
        end
    end
end