using DataStructures: OrderedDict
using PrettyTables

# define `Subjects` as uppercase strings.

SubjectCounts = OrderedDict{String, Int}

struct Division
    grade::Int
    section::Int
    section_str::String
    __str__::String  # precomputed string representation of the division

    # if section_str is not provided, infer it (only if section in [1,26])
    function Division(grade::Int, section::Int)
        if (section < 1) || (section > 26)
            error("`section::Int` not in bounds [1, 26]. Provide the `section_str::String` parameter.")
        end
        # uppercase letters start from char 65
        section_str = string(Char(64 + section))
        return Division(grade, section, section_str)
    end
    function Division(grade::Int, section::Int, section_str::String)
        # precompute __str__
        __str__ = "$(grade)-$(section_str)"
        return new(grade, section, section_str, __str__)
    end
end
Base.string(d::Division) = d.__str__
Base.show(io::IO, d::Division) = print(io, string(d))


struct Teacher
    name::String
    id::String
    subjects::Vector{String}
    grades::Vector{Int}
    __str__::String  # precomputed string representation of the teacher
    function Teacher(name::String, id::String, subjects::Vector{String}, grades::Vector{Int})
        # precompute __str__
        __str__ = id
        return new(name, id, subjects, grades, __str__)
    end
end
Base.string(t::Teacher) = t.__str__
Base.show(io::IO, t::Teacher) = print(io, string(t))


mutable struct Period
    subject::Union{String,Nothing}
    teacher::Union{Teacher,Nothing}
end
Base.string(p::Period) = "$(p.subject) ($(string(p.teacher)))"
Base.show(io::IO, p::Period) = print(io, string(p))


mutable struct Timetable
    # number of periods in each row
    numperiods::Vector{Int}
    # number of times a subject must occur
    subjectcounts::SubjectCounts
    # subjects to consider
    subjects::Vector{String}
    # teachers to consider
    teachers::Vector{Teacher}
    # subjects mapped to list of valid teachers (both as strs)
    subjectteachers::OrderedDict{String,Vector{String}}
    # teachers' string mapped to teacher structs 
    teacher_strs::OrderedDict{String,Teacher}
    # division of the timetable
    division::Division
    # array structure representing the actual data
    data::Vector{Vector{Period}}

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
        return new(numperiods, subjectcounts, subjects, teachers,
        subjectteachers, teacher_strs, division, data)
    end
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
end
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


mutable struct Schedule
    data::OrderedDict{String,Timetable}
    function Schedule(timetables...)
        # mapping div's string representation to timetable
        data = OrderedDict{String,Timetable}()
        for tt in timetables
            div = string(tt.division)
            data[div] = tt
        end
        return new(data)
    end
end
Base.string(s::Schedule) = join(string.(values(s.data)),"\n")
Base.show(io::IO, s::Schedule) = print(io, string(s))

# call `modify!` on concerned timetable
modify!(s::Schedule, var::String, val::String) = modify!(s.data[split(var, "_")[1]], var, val)

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
