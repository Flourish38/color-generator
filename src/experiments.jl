include("generation_algorithms.jl")
include("discord_colors.jl")

begin
    discord_diff_map_prot = ColorDiffMap(c -> protanopic(c, 0.8))
    println("Computing discord color map. This will take a while, but the ETA will shrink rapidly as the computation proceeds.")
    updates_log = @time add_colors!(discord_diff_map_prot, all_discord_colors)
    nothing
end
begin
    prot_colors = so_distinguishable_colors(20; map=discord_diff_map_prot, thresh=10000000)
    display_colors(prot_colors, discord_diff_map_prot)    
end

begin
    discord_diff_map_deut = ColorDiffMap(c -> deuteranopic(c, 0.9))
    println("Computing discord color map. This will take a while, but the ETA will shrink rapidly as the computation proceeds.")
    updates_log = @time add_colors!(discord_diff_map_deut, all_discord_colors)
    nothing
end
begin
    deut_colors = so_distinguishable_colors(20; map=discord_diff_map_deut, thresh=10000000)
    display_colors(deut_colors, discord_diff_map_deut)
end

begin
    discord_diff_map_trit = ColorDiffMap(c -> tritanopic(c, 0.8))
    println("Computing discord color map. This will take a while, but the ETA will shrink rapidly as the computation proceeds.")
    updates_log = @time add_colors!(discord_diff_map_trit, all_discord_colors)
    nothing
end
begin
    trit_colors = so_distinguishable_colors(20; map=discord_diff_map_trit, thresh=10000000)
    display_colors(trit_colors, discord_diff_map_trit)    
end
