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
        (discord_dist_map_prot, 15.0),
        (discord_dist_map_deut, 15.0),
        (discord_dist_map_trit, 15.0)
    ]
    discord_dist_map_weights = map_threshs_to_weights(discord_dist_map_threshs)
    colors = thresh_distinguishable_colors(discord_dist_map_threshs)
    display_colors(colors, discord_dist_map_weights)
end

begin
    prev_score = w_score(colors, discord_dist_map_weights)
    refine_colors!(colors, discord_dist_map_weights, Minute(15))
    if w_score(colors, discord_dist_map_weights) != prev_score
        println()
        display_colors(colors, discord_dist_map_weights)
    end
end