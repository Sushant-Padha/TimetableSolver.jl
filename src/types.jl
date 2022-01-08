using DataStructures: OrderedDict
using PrettyTables

# define `Subjects` as uppercase strings.

"""
    SubjectCounts

Type for counting the number of times each subject appears in a timetable.

Alias for `OrderedDict{String, Int}`.
"""
SubjectCounts = OrderedDict{String, Int}

"""
    Division

Type for representing a division of a timetable.

# Constructors
- `Division(grade::Int, section::Int)`  
- `Division(grade::Int, section::Int, section_str::String)`

# Fields
- `grade::Int`: The grade of the division.
- `section::Int`: The section of the division.
- `section_str::String`: The section of the division as a string.
- `__str__::String`: The precomputed string representation of the division.
"""
struct Division
    grade::Int
    section::Int
    section_str::String
    __str__::String  # precomputed string representation of the division
end

"""
    Division(grade::Int, section::Int)

Return a division with the given grade and section.
`section_str` is inferred as the nth letter of the alphabet, where n=`section`.

Call the second constructor with `section_str` as the third argument.
"""
function Division(grade::Int, section::Int)
    if (section < 1) || (section > 26)
        error("`section::Int` not in bounds [1, 26]. Provide the `section_str::String` parameter.")
    end
    # uppercase letters start from char 65
    section_str = string(Char(64 + section))
    return Division(grade, section, section_str)
end

"""
    Division(grade::Int, section::Int, section_str::String)

Return a division with the given grade, section, section string and precomputed string representation.
"""
function Division(grade::Int, section::Int, section_str::String)
    # precompute __str__
    __str__ = "$(grade)-$(section_str)"
    return Division(grade, section, section_str, __str__)
end
Base.string(d::Division) = d.__str__
Base.show(io::IO, d::Division) = print(io, string(d))

"""
    Teacher

Type for representing a teacher in the timetable.

# Constructors
- `Teacher(name::String, id::String, subjects::Vector{String}, grades::Vector{Int})`

# Fields
- `name::String`: The name of the teacher.
- `id::String`: The unique id of the teacher.
- `subjects::Vector{String}`: The subjects taught by the teacher.
- `grades::Vector{Int}`: The grades taught by the teacher.
- `__str__::String`: The precomputed string representation of the teacher.
"""
struct Teacher
    name::String
    id::String
    subjects::Vector{String}
    grades::Vector{Int}
    __str__::String  # precomputed string representation of the teacher
end
"""
    Teacher(name::String, id::String, subjects::Vector{String}, grades::Vector{Int})

Return a teacher with the given name, id, subjects, grades and precomputed string representation.
"""
function Teacher(name::String, id::String, subjects::Vector{String}, grades::Vector{Int})
    # precompute __str__
    __str__ = id
    return Teacher(name, id, subjects, grades, __str__)
end
Base.string(t::Teacher) = t.__str__
Base.show(io::IO, t::Teacher) = print(io, string(t))


"""
    Period

Mutable type for representing a period in the timetable.
Empty period is initialized with `nothing` as both arguments.

# Fields
- `subject::Union{String,Nothing}`: The subject of the period.
- `teacher::Union{Teacher,Nothing}`: The teacher of the period.
"""
mutable struct Period
    subject::Union{String,Nothing}
    teacher::Union{Teacher,Nothing}
end
Base.string(p::Period) = "$(p.subject) ($(string(p.teacher)))"
Base.show(io::IO, p::Period) = print(io, string(p))

"""
    Timetable

Mutable type for representing a timetable.

# Constructors
- `Timetable(numperiods::Vector{Int}, subjectcounts::SubjectCounts, teachers::Vector{Teacher}, division::Division)`

# Fields
- `numperiods::Vector{Int}`: The number of periods in each row.
- `subjectcounts::SubjectCounts`: The number of times subjects must occur in the timetable, in total.
- `subjects::Vector{String}`: The subjects in the timetable.
- `teachers::Vector{Teacher}`: The teachers in the timetable.
- `subjectteachers::OrderedDict{String, Vector{Teacher}}`: The teachers teaching each subject.
- `teacher_strs::OrderedDict{String, Teacher}`: The teachers' string representations mapped to objects.
- `division::Division`: The division of the timetable.
- `data::Vector{Vector{Period}}`: The timetable data, as a vector of vectors of periods.

# Notes
- Only fields `numperiods`, `subjectcounts`, `teachers` and `division` are passed. The rest are inferred.
- See the constructor for the same.
"""
mutable struct Timetable
    numperiods::Vector{Int}
    subjectcounts::SubjectCounts
    subjects::Vector{String}
    teachers::Vector{Teacher}
    subjectteachers::OrderedDict{String,Vector{String}}
    teacher_strs::OrderedDict{String,Teacher}
    division::Division
    data::Vector{Vector{Period}}
end
"""
    Timetable(numperiods::Vector{Int}, subjectcounts::SubjectCounts, teachers::Vector{Teacher}, division::Division)

Return a timetable with the given number of periods, subject counts, teachers and division.

# Notes
- Fields `subjects`, `subjectteachers`, `teacher_strs` and `data` are inferred.
- `data` stores the actual vector of vectors of periods, initialized with (`nothing`, `nothing`) as arguments.
"""
function Timetable(numperiods::Vector{Int}, subjectcounts::SubjectCounts,
    teachers::Vector{Teacher}, division::Division)
    subjects = collect(String, keys(subjectcounts))
    subjectteachers = get_subjectteachers(subjects,teachers)
    teacher_strs = OrderedDict(zip(string.(teachers), teachers))
    # fill data
    data = [[] for _ in numperiods]
    for (i,n) in enumerate(numperiods)
        data[i] = [Period(nothing, nothing) for _ in 1:n]
    end
    return Timetable(numperiods, subjectcounts, subjects, teachers,
    subjectteachers, teacher_strs, division, data)
end

"""
    get_subjectteachers(subjects::Vector{String}, teachers::Vector{Teacher})

Return an OrderedDict mapping subjects to valid teachers, based on `subjects` and `teachers`.
"""
function get_subjectteachers(subjects::Vector{String},teachers::Vector{Teacher})
    # initialize dict with empty list mapped to each subject
    subjectteachers = OrderedDict{String,Vector{String}}(s=>[] for s in subjects)
    for t in teachers, s in subjects
        if s in t.subjects
            # push the teacher to the subject's list
            push!(subjectteachers[s], string(t))
        end
    end
    # filter out empty lists
    subjectteachers = filter(x->length(x)>0, subjectteachers)
    return subjectteachers
end
"""
    Base.string(tt::Timetable)::String

`Base.string` method for type Timetable.

Return a pretty table representation of the timetable.

# Notes
- Use the [`PrettyTables`](https://github.com/ronisbr/PrettyTables.jl) library to return a table-like string.
- Rows are numbered from 1 to `length(data)` and columns are numbered P1, P2 ... to longest row in data (`max(length.(data)...)`).
- Column 1 header is the division name.
- Call division and teacher's `Base.string` method for string representation. 
"""
function Base.string(tt::Timetable)
    data = tt.data
    m, n = length(data), max(length.(data)...)
    header = vcat([string(tt.division)], ["P"*string(i) for i in 1:n])
    data_matrix = fill("", (m, n+1))
    for (i,row) in enumerate(data)
        matrix_row = string.(row)
        data_matrix[i,1] = string(i)
        data_matrix[i,2:lastindex(matrix_row)+1] = matrix_row
    end
    s = pretty_table(String, data_matrix, header=header, alignment=:L)
    return s
end
Base.show(io::IO, tt::Timetable) = print(io, string(tt))

"""
    Schedule

Mutable type for representing a schedule, i.e., a collection of timetables.

# Constructors
- `Schedule(timetables...)`

# Fields
- `data::OrderedDict{String,Timetable}`: The timetables in the schedule mapped to their division's string representation.
"""
mutable struct Schedule
    data::OrderedDict{String,Timetable}
end
"""
    Schedule(timetables...)

Return a schedule instance using the given timetables.

# Notes
`data` is an OrderedDict mapping division's string representation to the timetable.
"""
function Schedule(timetables...)
    # mapping div's string representation to timetable
    data = OrderedDict{String,Timetable}()
    for tt in timetables
        div = string(tt.division)
        data[div] = tt
    end
    return Schedule(data)
end

"""
    Base.string(s::Schedule)::String

`Base.string` method for type Schedule.

Return pretty table representation of the timetables.

# Notes
- Call the `Base.string` method for each timetable in the schedule and fill newlines in between.
"""
Base.string(s::Schedule) = join(string.(values(s.data)),"\n")
Base.show(io::IO, s::Schedule) = print(io, string(s))

"""
    modify!(s::Schedule, var::String, val::String)

Modify schedule `s` by replacing the value of the field `var` with `val`.

# Notes
- Modify the schedule `s` in place.
- Both `var` and `val` are strings.
- Call `modify!()` on the correct timetable in `s` with the same arguments.
"""
modify!(s::Schedule, var::String, val::String) = modify!(s.data[split(var, "_")[1]], var, val)

"""
    modify!(tt::Timetable, var::String, val::String)

Modify timetable `tt` by replacing the value of the field `var` with `val`.

# Notes
- Modify the timetable `tt` in place.
- Both `var` and `val` are strings.
- Row, period and type of variable are inferred by splitting `var` at `"_"`, and taking last 3 elements.
- If `type == "subject"` then the subject of the corresponding row and period is set to `val`.
- If `type == "teacher"` then the teacher of the corresponding row and period is set to `val` (after getting teacher object from teacher string using `tt.teacher_strs`).
"""
function modify!(tt::Timetable, var::String, val::String)
    # split var
    _, row, period, type = split(var, "_")
    row, period = parse(Int, row), parse(Int, period)
    
    # if else based on type
    if type == "subject"
        # change subject to val
        tt.data[row][period].subject = val
    elseif type == "teacher"
        # change teacher to Teacher instance matching val
        tt.data[row][period].teacher = tt.teacher_strs[val]
    else
        error("Invalid type $(type)")
    end
end
