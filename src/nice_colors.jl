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
Number of iterations: 145213568  Time: 0 Time: 0:40:04 (16.56 μs/it)
  score:             13.223738789246072
  best_score:        17.157537748704137
  last_improvement:  45234331
=#
so_40_171 = parse.(RGB, ["#FC699B", "#B8979D", "#980337", "#B45D54", "#A31500", "#FE6501", "#DFA379", "#894E0A", "#8C7561", "#BC7A04", "#FCC548", "#7D6B07", "#A49D75", "#F9F727", "#92CA04", "#628A07", "#39550D", "#677162", "#9ECEA4", "#01B351", "#2EFF89", "#018155", "#03B09E", "#03696D", "#09DBEE", "#7C9DA4", "#18B5F9", "#0E5F92", "#777F9A", "#0B83FB", "#B2A6FA", "#5F5299", "#0F13F2", "#AC0BD4", "#A86EAD", "#FF0AFE", "#F6ADE5", "#83086C", "#7E616D", "#D50B7E"])

#=
Number of iterations: 236399482  Time: 0 Time: 1:21:30 (20.69 μs/it)
  score:             10.932998142989415
  best_score:        15.878677642990112
  last_improvement:  136406986
=#
so_50_158 = parse.(RGB, ["#D60662", "#86013A", "#FEA6B4", "#AA918F", "#FE6E68", "#834D48", "#D62A2F", "#8E0702", "#B06F52", "#F9B08E", "#FF6B16", "#924805", "#C67C08", "#786D5F", "#B79E78", "#EEB000", "#886602", "#A59812", "#F3E468", "#69790E", "#99C80F", "#354C08", "#808C6B", "#35A214", "#A4C49E", "#6EEB80", "#526653", "#00772F", "#02B27F", "#04EBCB", "#148674", "#26BCC1", "#A7FAFF", "#8EA0A3", "#0E6777", "#0A93B4", "#85C7ED", "#055691", "#666D7E", "#0F8BF3", "#9E9EC0", "#4460FD", "#5B4B99", "#0500D4", "#9270BC", "#D891D4", "#FE2CFF", "#C811AB", "#834E74", "#B86F8A"])

#=
Number of iterations: 17164310   Time: 0:12:03 (42.16 μs/it)
  score:             11.184050314237812
  best_score:        12.344981165971474
  last_improvement:  7179034
=#
# ... I don't think this is super useful, but it's provided just in case.
so_0100_123 = parse.(RGB, ["#8B7F82", "#B87C8D", "#F199B1", "#B60F54", "#75002D", "#8F6369", "#F11164", "#FE7270", "#A61027", "#C0605C", "#713C38", "#FE0835", "#6C0101", "#D00100", "#985239", "#C09E92", "#EF4A0E", "#EB8D68", "#FBBEA2", "#A07864", "#B8611E", "#6E5647", "#753803", "#EE780A", "#FFA001", "#BC7C0C", "#C39B68", "#FFC880", "#795302", "#846F4C", "#C99E0C", "#BAAF9B", "#F5DD0A", "#CFC17F", "#4F4B03", "#B4B50E", "#918E5A", "#6D6C64", "#FEFC97", "#6E7411", "#7E9603", "#8C8E84", "#96DA1B", "#4F5A3C", "#1F3B00", "#2F6103", "#8ABA65", "#608A47", "#B5CCAD", "#03AA2B", "#B1F2AD", "#80A180", "#1BFD78", "#027642", "#02CB7A", "#005131", "#0EA16F", "#4E846F", "#01AAA0", "#47615E", "#A5DDD8", "#0CFDF3", "#86ADAD", "#678487", "#05E0F8", "#017684", "#179AAE", "#025670", "#13C1F9", "#0B84B5", "#9FBCD9", "#5B6876", "#818FA3", "#47A3F5", "#1266AB", "#2C79FC", "#203F86", "#6F75AE", "#044BE2", "#C4B3F9", "#8E73FC", "#0C0BB3", "#7452B6", "#564176", "#6A0FEE", "#CE81F7", "#B418FF", "#806589", "#A567BA", "#7A1593", "#AFA4B0", "#BD96C1", "#F3C5ED", "#E819CD", "#695E66", "#B60692", "#6D0051", "#E26EB4", "#B85282", "#7E3F5B"])


begin
    n = 1000
    so_colors = so_distinguishable_colors(n; thresh=1000000)
    println()
    println(collect(map(x -> "#" * hex(x), so_colors)))
    @show score(so_colors)
    so_colors
end