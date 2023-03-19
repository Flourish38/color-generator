@time begin
    include("src_old/monte_carlo.jl")
    include("discord_colors.jl")
end

# Feel free to edit these numbers!
number_of_colors_generated = 20
minimum_iterations = 1000000
minimum_iterations_since_last_improvement = 100000

mc_colors = mc_distinguishable_colors(number_of_colors_generated, discord_background_colors; its=minimum_iterations, thresh=minimum_iterations_since_last_improvement)
println(collect(map(x -> "#" * x, hex.(mc_colors))))