using Colors, IterTools, FixedPointNumbers, ProgressMeter, BSON

dark_background = HSL(223, 0.067, 0.206)
light_background = HSL(0, 0, 1.)

dark_member_background = HSL(220, 0.065, 0.18)
light_member_background = HSL(220, 0.13, 0.955)

begin
    aurora = [HSL(220, 0.865, 0.175),
        HSL(238, 0.764, 0.416),
        HSL(184, 0.78, 0.339),
        HSL(169, 0.602, 0.325),
        HSL(230, 0.925, 0.263)]
    chroma_glow = [HSL(183, 0.863, 0.402),
        HSL(258, 0.898, 0.463),
        HSL(298, 0.909, 0.343),
        HSL(265, 1.0, 0.663),
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
    neon_nights = [HSL(176, 0.988, 0.331),
        HSL(259, 0.395, 0.553),
        HSL(314, 0.525, 0.463)]
    retro_raincloud = [HSL(202, 0.47, 0.429),
        HSL(241, 0.296, 0.61)]
    retro_storm = [HSL(202, 0.47, 0.429),
        HSL(241, 0.278, 0.473)]
    sepia = [HSL(33, 0.142, 0.457),
        HSL(36, 0.468, 0.243)]
    strawberry_lemonade = [HSL(327, 0.741, 0.394),
        HSL(28, 0.717, 0.443),
        HSL(40, 0.802, 0.525)]
    sunrise = [HSL(327, 0.42, 0.439),
        HSL(27, 0.449, 0.58),
        HSL(50, 0.463, 0.445)]
    sunset = [HSL(259, 0.556, 0.353),
        HSL(22, 0.667, 0.576)]
    under_the_sea = [HSL(115, 0.105, 0.429),
        HSL(159, 0.204, 0.433),
        HSL(175, 0.109, 0.467)]
    gradient_themes = [aurora, chroma_glow, citrus_sherbert, cotton_candy, crimson_moon, desert_khaki, dusk, easter_egg, forest, hanami, lofi_vibes, mars, midnight_blurple, mint_apple, neon_nights, retro_raincloud, retro_storm, sepia, sunrise, strawberry_lemonade, sunset, under_the_sea]
    dark_gradient_themes = [aurora, chroma_glow, crimson_moon, dusk, forest, mars, midnight_blurple, neon_nights, retro_storm, sepia, strawberry_lemonade, sunset, under_the_sea]
    light_gradient_themes = [citrus_sherbert, cotton_candy, desert_khaki, easter_egg, hanami, lofi_vibes, mint_apple, retro_raincloud, sunrise]
    @assert all([x in dark_gradient_themes || x in light_gradient_themes for x in gradient_themes])
    @show length(gradient_themes)
end

const A = 0.055
const Γ = 2.4
const X = 0.04045
const Φ = 12.92

rgb(c::Colorant) = red(c), green(c), blue(c)
sRGB_to_linear(c::Fractional) = c <= X ? c / Φ : ((c + A)/(1 + A))^Γ
linear_to_sRGB(c::Fractional) = clamp(c <= X/Φ ? Φ * c : (1 + A)c^(1 / Γ) - A, 0, 1)

function overlay_color(base::RGB, overlay::RGBA)
    α = alpha(overlay)
    RGB(α*overlay.r + (1-α)*base.r, α*overlay.g + (1-α)*base.g, α*overlay.b + (1-α)*base.b)
end
@inline overlay_color(base::Color, overlay::RGBA) = overlay_color(RGB(base), overlay)
@inline overlay_color(base::Color, overlay::ColorAlpha) = overlay_color(base, RGBA(overlay))



dark_gradient_theme_overlay = RGBA(0, 0, 0, 0.8)
light_gradient_theme_overlay = RGBA(1, 1, 1, 0.9)


brand_500 = HSL(235, 0.856, 0.647)
yellow_300 = HSL(40, 0.864, 0.569)
red_400 = HSL(359, 0.873, 0.598)
brand_360 = HSL(235, 0.861, 0.775)
primary_900 = HSL(0, 0, 0.008)
primary_500 = HSL(228, 0.06, 0.325)
primary_400 = HSL(223, 0.058, 0.529)

begin
    ephemeral_message_overlay = HSLA(brand_500, 0.05)
    ephemeral_message_hover_overlay = HSLA(brand_500, 0.1)
    mentioned_message_overlay = HSLA(yellow_300, 0.1)
    mentioned_message_hover_overlay_dark = HSLA(yellow_300, 0.08)
    mentioned_message_hover_overlay_light = HSLA(yellow_300, 0.2)
    automod_message_overlay = HSLA(red_400, 0.05)
    automod_message_hover_overlay = HSLA(red_400, 0.1)
    highlight_message_overlay_dark = HSLA(brand_360, 0.08) 
    highlight_message_overlay_light = HSLA(brand_360, 0.1) 
    highlight_message_hover_overlay_dark = HSLA(brand_360, 0.06)
    highlight_message_hover_overlay_light = HSLA(brand_360, 0.2)
    message_hover_overlay_dark = HSLA(primary_900, 0.06)
    message_hover_overlay_light = HSLA(primary_900, 0.03)

    member_hover_overlay_dark = HSLA(primary_500, 0.3)
    member_selected_overlay_dark = HSLA(primary_500, 0.6)

    member_hover_overlay_light = HSLA(primary_400, 0.16)
    member_selected_overlay_light = HSLA(primary_400, 0.24)

    dark_message_overlays = [ephemeral_message_overlay, ephemeral_message_hover_overlay, mentioned_message_overlay, mentioned_message_hover_overlay_dark, automod_message_overlay, automod_message_hover_overlay,
        highlight_message_overlay_dark, highlight_message_hover_overlay_dark, message_hover_overlay_dark]
    dark_member_overlays = [member_hover_overlay_dark, member_selected_overlay_dark]
    dark_background_overlays = vcat(dark_message_overlays, dark_member_overlays)

    light_message_overlays = [ephemeral_message_overlay, ephemeral_message_hover_overlay, mentioned_message_overlay, mentioned_message_hover_overlay_light, automod_message_overlay, automod_message_hover_overlay,
        highlight_message_overlay_light, highlight_message_hover_overlay_light, message_hover_overlay_light]
    light_member_overlays = [member_hover_overlay_light, member_selected_overlay_light]
    light_background_overlays = vcat(light_message_overlays, light_member_overlays)
end

role_menu_background_dark = HSL(220, 0.081, 0.073)
role_menu_hover = HSL(235, 0.514, 0.524)

#base_dark_theme_colors = vcat(dark_background, overlay_color.(dark_background, dark_message_overlays), dark_member_background, overlay_color.(dark_member_background, dark_member_overlays), role_menu_background_dark, role_menu_hover)
#base_light_theme_colors = vcat(light_background, overlay_color.(light_background, light_message_overlays), light_member_background, overlay_color.(light_member_background, light_member_overlays), role_menu_hover)

function get_all_gradient_colors(gradient_themes, gradient_theme_overlay)
    all_gradient_colors = Set{RGB{N0f8}}()
    for theme in gradient_themes
        for (color_a, color_b) in partition(theme, 2, 1)
            color_a = RGB(color_a)
            color_b = RGB(color_b)
            length = 2
            new_colors = true
            while new_colors
                length *= 2
                new_colors = false
                color_range = RGB{N0f8}.(overlay_color.(range(color_a, color_b; length=length), gradient_theme_overlay))
                for color in color_range
                    if !(color in all_gradient_colors)
                        new_colors = true
                        push!(all_gradient_colors, color)
                    end
                end
            end
        end
    end
    all_gradient_colors
end

#all_darkened_gradient_colors = get_all_gradient_colors(dark_gradient_themes, dark_gradient_theme_overlay)

function modify_all_gradient_colors(all_gradient_colors, background_overlays)
    all_modified_gradient_colors = Set{RGB{N0f8}}()
    for color in all_gradient_colors
        union!(all_modified_gradient_colors, RGB{N0f8}.(overlay_color.(color, background_overlays)))
    end
    all_modified_gradient_colors
end

#all_darkened_gradient_colors_modified = union(all_darkened_gradient_colors, modify_all_gradient_colors(all_darkened_gradient_colors, dark_background_overlays))

sat_multiply(col::HSL, sat) = HSL(col.h, col.s * sat, col.l)
sat_multiply(col::HSLA, sat) = HSLA(col.h, col.s * sat, col.l, col.alpha)

function all_sat_gradient_colors(gradient_themes, gradient_theme_overlay, background_overlays)
    all_sat_gradient_colors = Set{RGB{N0f8}}()
    for sat in 0.0:0.05:1.0
        all_gradient_colors = get_all_gradient_colors(map.(x -> sat_multiply(x, sat), gradient_themes), gradient_theme_overlay)
        union!(all_sat_gradient_colors, modify_all_gradient_colors(all_gradient_colors, map(x -> sat_multiply(x, sat), background_overlays)))
        union!(all_sat_gradient_colors, all_gradient_colors)
    end
    all_sat_gradient_colors
end

all_darkened_sat_colors = all_sat_gradient_colors(dark_gradient_themes, dark_gradient_theme_overlay, dark_background_overlays)
all_lightened_sat_colors = all_sat_gradient_colors(light_gradient_themes, light_gradient_theme_overlay, light_background_overlays)

begin
    all_base_sat_colors = Set{RGB{N0f8}}()
    for sat in 0.0:0.05:1.0
        # You might not want these, since they're only really for admin usage anyways
        #= = =
        push!(all_base_sat_colors, RGB{N0f8}(sat_multiply(role_menu_background_dark, sat)))
        push!(all_base_sat_colors, RGB{N0f8}(sat_multiply(role_menu_hover, sat)))
        # = = =#
        sat_dark_background = sat_multiply(dark_background, sat)
        sat_dark_member_background = sat_multiply(dark_member_background, sat)
        sat_light_background = sat_multiply(light_background, sat)
        sat_light_member_background = sat_multiply(light_member_background, sat)
        union!(all_base_sat_colors, RGB{N0f8}.([sat_dark_background, sat_dark_member_background, sat_light_background, sat_light_member_background]))
        union!(all_base_sat_colors, RGB{N0f8}.(overlay_color.(sat_dark_background, dark_message_overlays)))
        union!(all_base_sat_colors, RGB{N0f8}.(overlay_color.(sat_dark_member_background, dark_member_overlays)))
        union!(all_base_sat_colors, RGB{N0f8}.(overlay_color.(sat_light_background, light_message_overlays)))
        union!(all_base_sat_colors, RGB{N0f8}.(overlay_color.(sat_light_member_background, light_member_overlays)))
    end
end

all_discord_colors = collect(union(all_darkened_sat_colors, all_lightened_sat_colors, all_base_sat_colors)); @show length(all_discord_colors)

include("color_dist_map.jl")
begin
    discord_dist_map = if isfile("discord_dist_map.bson")
        ColorDistMap("discord_dist_map.bson")
    else
        _map = ColorDistMap()
        println("Computing discord color map. This will take a while, but the ETA will shrink rapidly as the computation proceeds. On my machine, it takes 3-7 minutes.")
        add_colors!(_map, all_discord_colors)
        save(_map, "discord_dist_map.bson")
        _map
    end
    nothing
end
if true
    discord_dist_map_prot = if isfile("discord_dist_map_prot.bson")
        ColorDistMap("discord_dist_map_prot.bson")
    else
        _map = ColorDistMap(lab(protanopic))
        println("Computing protanopic discord color map.")
        add_colors!(_map, all_discord_colors)
        save(_map, "discord_dist_map_prot.bson")
        _map
    end
    discord_dist_map_deut = if isfile("discord_dist_map_deut.bson")
        ColorDistMap("discord_dist_map_deut.bson")
    else
        _map = ColorDistMap(lab(deuteranopic))
        println("Computing deuteranopic discord color map.")
        add_colors!(_map, all_discord_colors)
        save(_map, "discord_dist_map_deut.bson")
        _map
    end
    discord_dist_map_trit = if isfile("discord_dist_map_trit.bson")
        ColorDistMap("discord_dist_map_trit.bson")
    else
        _map = ColorDistMap(lab(tritanopic))
        println("Computing tritanopic discord color map.")
        add_colors!(_map, all_discord_colors)
        save(_map, "discord_dist_map_trit.bson")
        _map
    end
    discord_dist_map_contrast = if isfile("discord_dist_map_contrast.bson")
        ColorDistMap("discord_dist_map_contrast.bson")
    else
        _map = ColorDistMap(identity, contrast_ratio)
        println("Computing contrast ratio discord color map.")
        add_colors!(_map, all_discord_colors)
        __map = ColorDistMap(_map.array, identity, no_distance)
        save(__map, "discord_dist_map_contrast.bson")
        __map
    end
    nothing
end


nothing