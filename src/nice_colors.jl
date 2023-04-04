using Colors
include("generation_algorithms.jl")

# Most distinguishable color:  #FF2300  score: 38.16

#=
Number of iterations: 99910337   Time: 0:00:34 ( 0.34 μs/it)
  score:             36.01388263677119
  best_score:        36.345829328252954
  last_improvement:  409214
=#
so_02_363 = parse.(RGB, ["#FF1848", "#009900"])

#=
Number of iterations: 99764827   Time: 0:01:01 ( 0.62 μs/it)
  score:             35.86700297983394
  best_score:        36.19190897501695
  last_improvement:  15084
=#
so_03_362 = parse.(RGB, ["#E94E06", "#00990A", "#F80099"])

#=
Number of iterations: 157026582  Time: 0 Time: 0:02:34 ( 0.99 μs/it)
  score:             31.624678701351826
  best_score:        32.36567507695348
  last_improvement:  57166594
=#
so_04_323 = parse.(RGB, ["#FD002C", "#B57600", "#00A53D", "#F402CB"])

#=
Number of iterations: 99430806   Time: 0:02:12 ( 1.33 μs/it)
  score:             25.94702598310272
  best_score:        31.48763664399
  last_improvement:  78995
=#
so_05_315 = parse.(RGB, ["#D33C01", "#A18001", "#0B9180", "#0081FE", "#DD2381"])

#=
Number of iterations: 100018701  Time: 0 Time: 0:03:29 ( 2.10 μs/it)
  score:             24.03961293815218
  best_score:        31.43506307578402
  last_improvement:  479976
=#
so_06_314 = parse.(RGB, ["#ED1139", "#C47601", "#759301", "#00928F", "#0281FD", "#EF03DC"])

#=
Number of iterations: 106343205  Time: 0 Time: 0:04:31 ( 2.56 μs/it)
  score:             26.574906927410744
  best_score:        30.439636166755225
  last_improvement:  6558413
=#
so_07_304 = parse.(RGB, ["#E0004C", "#FE6F0D", "#978000", "#02C105", "#019695", "#2881F2", "#DC1FFE"])

#=
Number of iterations: 249097723  Time: 0 Time: 0:11:40 ( 2.81 μs/it)
  score:             15.576555471673798
  best_score:        28.690767037974922
  last_improvement:  149338622
["#D70351", "#D25A01", "#A58E05", "#027A00", "#00D902", "#039F99", "#098EED", "#9F6CC5"]
=#

#=
Number of iterations: 182619203  Time: 0 Time: 0:10:58 ( 3.60 μs/it)
  score:             23.89247386934736
  best_score:        26.91953235399848
  last_improvement:  82649195
=#
so_10_269 = parse.(RGB, ["#FE6C79", "#BD2E00", "#F48718", "#A79B00", "#2D7711", "#08D93A", "#03A595", "#029CE2", "#877DAB", "#BF027A"])

#=
Number of iterations: 107838397  Time: 0 Time: 0:14:41 ( 8.17 μs/it)
  score:             18.140145299987328
  best_score:        22.341451957460574
  last_improvement:  7858663
=#
so_20_223 = parse.(RGB, ["#B80224", "#FF665D", "#C36303", "#EDA90D", "#766801", "#8F8B7C", "#FBFF00", "#99AB2E", "#6AF876", "#046A25", "#05A473", "#1CF0DD", "#398892", "#05A8FF", "#2D69C6", "#A28DE6", "#9C0CFE", "#FF37CA", "#A4086C", "#967381"])

#=
Number of iterations: 166753352  Time: 0 Time: 0:33:54 (12.20 μs/it)
  score:             16.085086431481194
  best_score:        19.40115359631186
  last_improvement:  66754667
=#
so_30_194 = parse.(RGB, ["#FF829E", "#ED014D", "#8F625F", "#9A1113", "#E04203", "#F99C79", "#8A4E09", "#C87B10", "#A4947E", "#FDBB08", "#9B9203", "#666002", "#CADA09", "#94B57E", "#309003", "#06EC30", "#095910", "#647662", "#86F6D2", "#019F8E", "#1EE0F7", "#0E7B91", "#00A8EA", "#7C7F8E", "#0073E7", "#2E32FF", "#7C5694", "#BA92C9", "#E41BAC", "#961255"])

#=
Number of iterations: 324680261  Time: 0 Time: 1:26:53 (16.06 μs/it)
  score:             11.257392131539858
  best_score:        17.25865765013152
  last_improvement:  224686401
=#
so_40_172 = parse.(RGB,["#D41464", "#F56E84", "#8C0A28", "#875D58", "#DA011A", "#B18B82", "#F75B10", "#852F00", "#FCAB81", "#9B6110", "#D78A07", "#AFA180", "#E1BC00", "#777368", "#958D08", "#69641D", "#A1C704", "#01A704", "#07FF21", "#9DC695", "#0E671F", "#5A8B64", "#16FFBE", "#09685D", "#00B2AA", "#8B9E9D", "#05F4FE", "#01859C", "#0CBCE8", "#015F96", "#80829B", "#417BFE", "#665897", "#2534FA", "#B38AF4", "#AB03C1", "#FE00DD", "#AA6C9A", "#FF94DD", "#7F3864"])


so_colors = so_distinguishable_colors(8; thresh=100000000)
println(collect(map(x -> "#" * hex(x), so_colors)))