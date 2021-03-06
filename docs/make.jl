using TimetableSolver
using Documenter

DocMeta.setdocmeta!(
    TimetableSolver, :DocTestSetup, :(using TimetableSolver); recursive=true
)

makedocs(;
    modules=[TimetableSolver],
    authors="sushant <sushant.padha@gmail.com>",
    repo="https://github.com/Sushant-Padha/TimetableSolver.jl/blob/{commit}{path}#{line}",
    sitename="TimetableSolver.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Sushant-Padha.github.io/TimetableSolver.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "How-To" => "how_to.md",
        "Explanation" => "explanation.md",
        "Reference" => ["reference/index.md", "reference/types.md", "reference/solver.md"],
    ],
)

deploydocs(; repo="github.com/Sushant-Padha/TimetableSolver.jl", devbranch="master")
