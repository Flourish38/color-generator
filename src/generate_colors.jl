begin
    include("generation_algorithms.jl")
    include("discord_colors.jl")
end

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
