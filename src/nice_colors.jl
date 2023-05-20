using Colors
include("generation_algorithms.jl")

# Most distinguishable color:  #FF2400  score: 38.105

#=
Number of iterations: 99061115   Time: 0:01:11 ( 0.72 μs/it)
    score:             31.087569295575047
    best_score:        36.345829328252954
    last_improvement:  750467
=#
so_03_362 = parse.(RGB, ["#FF1746", "#009900"])

#=
Number of iterations: 99734278   Time: 0:02:38 ( 1.59 μs/it)
    score:             36.04738640468347
    best_score:        36.3260486703633
    last_improvement:  9812
=#
so_03_363 = parse.(RGB, ["#EE4B01", "#009901", "#F7009D"])

#=
Number of iterations: 99646889   Time: 0:04:01 ( 2.42 μs/it)
    score:             31.067393455940657
    best_score:        32.24136630281679
    last_improvement:  100054
=#
so_04_322 = parse.(RGB, ["#F0062E", "#B77600", "#188A02", "#F002D0"])

#=
Number of iterations: 99758589   Time: 0:06:04 ( 3.66 μs/it)
    score:             30.18875665859875
    best_score:        31.48763664399
    last_improvement:  67028
=#
so_05_314 = parse.(RGB, ["#DB2C09", "#A67D00", "#0A9388", "#0081FE", "#DC158C"])

#=
Number of iterations: 147862015  Time: 0 Time: 0:13:45 ( 5.59 μs/it)
    score:             24.695721267689414
    best_score:        31.309018545063033
    last_improvement:  47880088
=#
so_06_313 = parse.(RGB, ["#E5003B", "#CB7502", "#7B9100", "#03938E", "#0781FD", "#EA06E3"])

#=
Number of iterations: 106343205  Time: 0 Time: 0:04:31 ( 2.56 μs/it)
    score:             26.574906927410744
    best_score:        30.439636166755225
    last_improvement:  6558413
=#
so_07_304 = parse.(RGB, ["#E0004C", "#FE6F0D", "#978000", "#02C105", "#019695", "#2881F2", "#DC1FFE"])

#=
Number of iterations: 239460841  Time: 0 Time: 0:28:04 ( 7.03 μs/it)
    score:               24.972293974572555
    best_score:          28.658483808149192
    last_improvement:    139477612
=#
so_08_286 = parse.(RGB, ["#ED025E", "#E55F0D", "#A48A15", "#037B01", "#04DA02", "#058C8D", "#0E90FF", "#C438FF"])

#=
Number of iterations: 165609558  Time: 0 Time: 0:21:27 ( 7.77 μs/it)
    score:               21.749224111904038
    best_score:          26.932779751555856
    last_improvement:    65729916
=#
so_10_269 = parse.(RGB, ["#FF6B7B", "#C41100", "#D97B0E", "#A09D07", "#147604", "#2AFE14", "#02B190", "#0B97C9", "#857DA6", "#BD017E"])

#=
Number of iterations: 107838397  Time: 0 Time: 0:14:41 ( 8.17 μs/it)
    score:             18.140145299987328
    best_score:        22.341451957460574
    last_improvement:  7858663
=#
# Keeping these because they're nice
so_20_223_old = parse.(RGB, ["#B80224", "#FF665D", "#C36303", "#EDA90D", "#766801", "#8F8B7C", "#FBFF00", "#99AB2E", "#6AF876", "#046A25", "#05A473", "#1CF0DD", "#398892", "#05A8FF", "#2D69C6", "#A28DE6", "#9C0CFE", "#FF37CA", "#A4086C", "#967381"])

#=
Number of iterations: 195903326  Time: 0 Time: 1:08:42 (21.04 μs/it)
    score:             18.64482109780558
    best_score:        22.351242250721747
    last_improvement:  95965865
=#
so_20_223 = parse.(RGB, ["#A90644", "#FF0E30", "#BC8C76", "#A24B0A", "#ECA916", "#846D01", "#F1FF03", "#86A608", "#83877A", "#01731F", "#18FF78", "#08AF82", "#01CBDB", "#007A87", "#169EEE", "#0A60E2", "#A78AF9", "#856E89", "#B611D7", "#F8519E"])

#=
Number of iterations: 243181017  Time: 0 Time: 1:42:31 (25.29 μs/it)
    score:             6.425822962265318
    best_score:        19.35495727123023
    last_improvement:  143184204
=#
so_30_193 = parse.(RGB, ["#F50A65", "#9A0026", "#F89A8A", "#F9100E", "#856C60", "#964005", "#ED7A17", "#FAB62C", "#AE9971", "#7C6309", "#E1EA39", "#748D15", "#2E5802", "#30CD05", "#8CB892", "#088A59", "#77837C", "#10FEC0", "#046D6E", "#38F3FA", "#1CA6B4", "#037FB8", "#76B7F8", "#72739F", "#0A4BE6", "#B59CF6", "#A610C0", "#F93AF3", "#B68BA0", "#915170"])

#=
Number of iterations: 324680261  Time: 0 Time: 1:26:53 (16.06 μs/it)
    score:             11.257392131539858
    best_score:        17.25865765013152
    last_improvement:  224686401
=#
so_40_172 = parse.(RGB,["#D41464", "#F56E84", "#8C0A28", "#875D58", "#DA011A", "#B18B82", "#F75B10", "#852F00", "#FCAB81", "#9B6110", "#D78A07", "#AFA180", "#E1BC00", "#777368", "#958D08", "#69641D", "#A1C704", "#01A704", "#07FF21", "#9DC695", "#0E671F", "#5A8B64", "#16FFBE", "#09685D", "#00B2AA", "#8B9E9D", "#05F4FE", "#01859C", "#0CBCE8", "#015F96", "#80829B", "#417BFE", "#665897", "#2534FA", "#B38AF4", "#AB03C1", "#FE00DD", "#AA6C9A", "#FF94DD", "#7F3864"])


begin
    so_colors = so_distinguishable_colors(number_of_colors_generated; its=minimum_iterations, thresh=minimum_iterations_since_last_improvement)
    println()
    println(collect(map(x -> "#" * hex(x), so_colors)))
    @show score(so_colors)
    so_colors
end