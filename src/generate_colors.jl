begin
    include("generation_algorithms.jl")
    include("discord_colors.jl")
end

#=
begin
    # Feel free to edit these variables!
    diff_map = discord_diff_map
    number_of_colors_generated = 20
    minimum_iterations = 10000000
    minimum_iterations_since_last_improvement = 1000000
    so_colors = so_distinguishable_colors(number_of_colors_generated; its=minimum_iterations, thresh=minimum_iterations_since_last_improvement, map=diff_map)
    println()
    display_colors(so_colors, diff_map)
end
=#

begin
    discord_dist_map_threshs = [
        (discord_dist_map, 20.0),
        (discord_dist_map_prot, 10.0),
        (discord_dist_map_deut, 10.0),
        (discord_dist_map_trit, 10.0),
        (discord_dist_map_contrast, 2.0)
    ]
    discord_dist_map_weights = map_threshs_to_weights(discord_dist_map_threshs)
    colors = thresh_distinguishable_colors(discord_dist_map_threshs, Minute(1), Minute(1))
    sort!(colors, by = x -> LCHab(x).h)
    display_colors(colors, discord_dist_map_weights)
    n = length(colors)
end

begin
    prev_score = @show w_score(colors, discord_dist_map_weights, n)
    refine_colors!(colors, discord_dist_map_weights, Minute(15); num_unlocked=n, continuing=true)
    if n == length(colors) && w_score(colors, discord_dist_map_weights, n) != prev_score
        println()
        display_colors(hue_order(colors), discord_dist_map_weights)
    end
end

begin
    prev_score = @show w_score(colors, discord_dist_map_weights, n)
    refine_colors_local!(colors, discord_dist_map_weights, Second(600); num_unlocked=n, continuing=true)
    if n == length(colors) && w_score(colors, discord_dist_map_weights, n) != prev_score
        println()
        display_colors(hue_order(colors), discord_dist_map_weights)
    end
end

begin
    n = move_min_dist_to_end!(colors, find_min_score(get_scores(colors, discord_dist_map_weights, n))[2], n)
    sort!(@view(colors[1:n]), by = x -> LCHab(x).h)
    @show n
    colors
end

refine_all_colors!(colors, discord_dist_map_weights, Second(120); continuing=true)

begin
    print_colors(hue_order(colors))
    hue_order(colors)
end

backup_colors = deepcopy(colors)