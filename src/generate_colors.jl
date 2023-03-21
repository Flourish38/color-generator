@time begin
    include("src_old/monte_carlo.jl")
    include("discord_colors.jl")
    darkened_gradient_themes = [[overlay_color(color, dark_gradient_theme_overlay) for color in theme] for theme in dark_gradient_themes]
    lightened_gradient_themes = [[overlay_color(color, light_gradient_theme_overlay) for color in theme] for theme in light_gradient_themes]
    
    discord_background_colors = vcat([dark_background, dark_member_background, light_background, light_member_background], lightened_gradient_themes..., darkened_gradient_themes...)
end

# Feel free to edit these numbers!
number_of_colors_generated = 20
minimum_iterations = 1000000
minimum_iterations_since_last_improvement = 100000

mc_colors = mc_distinguishable_colors(number_of_colors_generated, discord_background_colors; its=minimum_iterations, thresh=minimum_iterations_since_last_improvement)
println(collect(map(x -> "#" * x, hex.(mc_colors))))