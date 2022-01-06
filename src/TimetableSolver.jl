module TimetableSolver

# include files
include("types.jl")
include("solver.jl")

# module name
export TimetableSolver
# from types.jl
export SubjectCounts, Division, Teacher, Period, Timetable, Schedule
# from solver.jl
export VariableData, get_model, get_solution, convertsolution, applysolution!, solve!

end
