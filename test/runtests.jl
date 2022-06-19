using TimetableSolver
using Test

"""
Array of all test files to run.
"""
const TESTFILENAMES = ["solver.jl", "types.jl"]

function runtests(testfilenames)
    for f in testfilenames
        # print what file we're running
        printstyled("Testing ./$(f) ...\n"; bold=true)
        printstyled("- - - - - - - - - - - - - - - - - - - - - - - - - -\n"; bold=true)
        # run it and store time taken and bytes used
        @testset "$f" begin
            include("./$(f)")
            println()
        end
        printstyled("\n###################################################\n\n"; bold=true)
    end
end

_, _time, bytes, _... = @timed runtests(TESTFILENAMES)

_time, mb = round(_time; digits=3), round(bytes / 1024 / 1024; digits=0)

printstyled("All tests took $time seconds, and used $(mb) megabytes.\n\n"; bold=true)
