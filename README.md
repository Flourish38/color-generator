# color-generator
Using various techniques to generate visually distinct colors

For first time setup, run `julia` (download [here](https://github.com/JuliaLang/juliaup), recommended you use `juliaup add release; julia default release`) and then do `] activate .`, and then `] instantiate`. (Remember, you use Ctrl+D to exit the `julia` REPL!)
In order to generate colors, just run `julia src/generate_colors.jl`, or `julia` and then `include("src/generate_colors.jl")`.

After a while, this will print out some number of hex codes (20 by default) that are visually distinct from all of the new discord background themes.
If you want to preview the colors without pasting them into some color picker website, you could run the code manually in VS Code with the Julia extension.

If you want more colors or you want to let the program run for longer, there are variables in `src/color_generator.jl`.
If you set `minimum_iterations_since_last_improvement` to anything over 10,000,000, you will see almost no difference except in computation time. 1,000,000 is probably good enough for most situations.