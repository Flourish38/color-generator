using Colors

dark_background = HSL(223, 0.067, 0.235)
light_background = HSL(0, 0, 1.)

dark_member_background = HSL(220, 0.065, 0.18)
light_member_background = HSL(220, 0.13, 0.955)

begin
    chroma_glow = [HSL(183, 0.863, 0.402),
        HSL(258, 0.898, 0.463),
        HSL(298, 0.909, 0.343),
        HSL(265, 1., 0.663),
        HSL(207, 0.755, 0.504)]
    citrus_sherbert = [HSL(40, 0.887, 0.582),
        HSL(18, 0.815, 0.639)]
    cotton_candy = [HSL(349, 0.768, 0.814),
        HSL(226, 0.926, 0.841)]
    crimson_moon = [HSL(0, 0.886, 0.31),
        HSL(0, 0.0, 0.0)]
    desert_khaki = [HSL(29, 0.324, 0.861),
        HSL(40, 0.413, 0.786),
        HSL(50, 0.496, 0.759)]
    dusk = [HSL(293, 0.135, 0.363),
        HSL(223, 0.41, 0.694)]
    easter_egg = [HSL(227, 0.584, 0.651),
        HSL(227, 0.31, 0.443)]
    forest = [HSL(124, 0.259, 0.106),
        HSL(143, 0.262, 0.239),
        HSL(76, 0.206, 0.247),
        HSL(117, 0.17, 0.416),
        HSL(43, 0.385, 0.478)]
    hanami = [HSL(352, 0.683, 0.802),
        HSL(43, 0.736, 0.763),
        HSL(116, 0.431, 0.745)]
    lofi_vibes = [HSL(220, 0.838, 0.806),
        HSL(184, 0.578, 0.786),
        HSL(130, 0.463, 0.788),
        HSL(76, 0.488, 0.755)]
    mars = [HSL(15, 0.363, 0.394),
        HSL(0, 0.362, 0.412)]
    midnight_blurple = [HSL(245, 0.551, 0.537),
        HSL(259, 0.745, 0.108)]
    mint_apple = [HSL(166, 0.397, 0.525),
        HSL(119, 0.404, 0.559),
        HSL(87, 0.483, 0.598)]
    retro_raincloud = [HSL(202, 0.47, 0.429),
        HSL(241, 0.296, 0.61)]
    sunrise = [HSL(327, 0.42, 0.439),
        HSL(27, 0.449, 0.58),
        HSL(50, 0.463, 0.445)]
    sunset = [HSL(259, 0.556, 0.353),
        HSL(22, 0.667, 0.576)]
    under_the_sea = [HSL(115, 0.105, 0.429),
        HSL(159, 0.204, 0.433),
        HSL(175, 0.109, 0.467)]
    gradient_themes = [chroma_glow, citrus_sherbert, cotton_candy, crimson_moon, desert_khaki, dusk, easter_egg, forest, hanami, lofi_vibes, mars, midnight_blurple, mint_apple, retro_raincloud, sunrise, sunset, under_the_sea]
    dark_gradient_themes = [chroma_glow, crimson_moon, dusk, forest, mars, midnight_blurple, sunset, under_the_sea]
    light_gradient_themes = [citrus_sherbert, cotton_candy, desert_khaki, easter_egg, hanami, lofi_vibes, mint_apple, retro_raincloud, sunrise]
    theme_matrix = fill(HSL(colorant"#1e1e1e"), length(gradient_themes) + 2, maximum(length.(gradient_themes)))
    theme_matrix[1, 1] = dark_background
    theme_matrix[1, 2] = dark_member_background
    theme_matrix[2, 1] = light_background
    theme_matrix[2, 2] = light_member_background
    for (i, theme) in enumerate(gradient_themes)
        for (j, col) in enumerate(theme)
            theme_matrix[i+2, j] = col
        end
    end
    theme_matrix
end

