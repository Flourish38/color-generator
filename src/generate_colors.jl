@time begin
    include("generation_algorithms.jl")
end

begin
    # Feel free to edit these numbers!
    number_of_colors_generated = 20
    minimum_iterations = 10000000
    minimum_iterations_since_last_improvement = 1000000
    so_colors = so_distinguishable_colors(number_of_colors_generated; its=minimum_iterations, thresh=minimum_iterations_since_last_improvement)
    println()
    println(collect(map(x -> "#" * hex(x), so_colors)))
    @show score(so_colors)
    so_colors
end
