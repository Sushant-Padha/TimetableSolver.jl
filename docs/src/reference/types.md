# Types

```@docs
SubjectCounts
Division
Division(grade::Int, section::Int)
Division(grade::Int, section::Int, section_str::String)
Teacher
Teacher(name::String, id::String, subjects::Vector{String}, grades::Vector{Int})
Period
Timetable
Timetable(numperiods::Vector{Int}, subjectcounts::SubjectCounts, teachers::Vector{Teacher}, division::Division)
get_subjectteachers(subjects::Vector{String},teachers::Vector{Teacher})
Base.string(tt::Timetable)
Schedule
Schedule(timetables...)
Base.string(s::Schedule)
modify!
```
