# Types

```@docs
TimetableSolver.SubjectCounts
TimetableSolver.Division
TimetableSolver.Division(grade::Int, section::Int)
TimetableSolver.Division(grade::Int, section::Int, section_str::String)
TimetableSolver.Teacher
TimetableSolver.Teacher(name::String, id::String, subjects::Vector{String}, grades::Vector{Int})
TimetableSolver.Period
TimetableSolver.Timetable
TimetableSolver.Timetable(numperiods::Vector{Int}, subjectcounts::SubjectCounts, teachers::Vector{Teacher}, division::Division)
TimetableSolver.get_subjectteachers(subjects::Vector{String},teachers::Vector{Teacher})
TimetableSolver.Base.string(tt::Timetable)
TimetableSolver.Schedule
TimetableSolver.Schedule(timetables...)
TimetableSolver.Base.string(s::Schedule)
TimetableSolver.modify!(s::Schedule, var::String, val::String)
TimetableSolver.modify!(tt::Timetable, var::String, val::String)
```
