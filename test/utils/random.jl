using TimetableSolver
using DataStructures: OrderedDict
using Random

# default values for certain functions
# maybe use greater values for longer output
# never use any lower values
const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const GRADES = 1:10
const SECTIONS = 1:26
const SUBJECT_LENGTH = 3
const NAME_LENGTH = 10
const ID_LENGTH = 5

function generate_schedule(
    nums::Vector{Int},
    numperiods::Vector{Int};
    subject_length::Int=SUBJECT_LENGTH,
    letters::String=LETTERS,
    grades::AbstractArray=GRADES,
    sections::AbstractArray=SECTIONS,
    name_length::Int=NAME_LENGTH,
    id_length::Int=ID_LENGTH,
)::Schedule
    # unpack n
    numsubjects, numteachers, numtimetables = nums
    # check values
    # timetables are combinations of grade and section
    if !(numtimetables <= length(grades) * length(sections))
        @show numtimetables
        @show grades
        @show sections
        error(
            "Number of timetables is greater than the total number of combinations of " *
            "grades and sections. Either reduce the number of timetables or " *
            "increase the possible values for `grades` and `sections`.\n" *
            "`numtimetables <= length(grades) * length(sections)` must be true.",
        )
    end
    # subjects are generated by using strings `subject_length` long with letters
    if !(numsubjects <= length(letters)^subject_length)
        @show numsubjects
        @show letters
        @show subject_length
        error(
            "Number of subjects is greater than the total number of possible strings of " *
            "given length and using given letters. Either reduce the number of subjects " *
            "or increase the chars in `letters` or the value of `subject_length`.\n" *
            "`numsubjects <= length(letters) ^ subject_length` must be true.",
        )
    end
    # teacher names are generated by using strings `name_length` long with letters
    if !(numteachers <= length(letters)^name_length)
        @show numteachers
        @show letters
        @show name_length
        error(
            "Number of teachers is greater than the total number of possible names of " *
            "given length and using given letters. Either reduce the number of teachers " *
            "or increase the chars in `letters` or the value of `name_length`.\n" *
            "`numteachers <= length(letters) ^ name_length` must be true.",
        )
    end
    # teacher ids are generated by using strings `id_length` long with letters
    if !(numteachers <= length(letters)^id_length)
        @show numteachers
        @show letters
        @show id_length
        error(
            "Number of teachers is greater than the total number of possible ids of " *
            "given length and using given letters. Either reduce the number of teachers " *
            "or increase the chars in `letters` or the value of `id_length`.\n" *
            "`numteachers <= length(letters) ^ id_length` must be true.",
        )
    end
    # get subjects
    subjects = generate_subjects(
        numsubjects; subject_length=subject_length, letters=letters
    )
    # get divisions
    divisions = generate_divisions(numtimetables; grades=grades, sections=sections)
    # get teachers
    teachers = generate_teachers(
        numteachers,
        subjects,
        divisions;
        letters=letters,
        name_length=name_length,
        id_length=id_length,
    )
    # get timetables
    timetables = generate_timetables(
        numtimetables, numperiods, subjects, teachers, divisions
    )
    # return schedule
    return Schedule(timetables...)
end

function generate_subjects(
    n::Int; subject_length::Int=SUBJECT_LENGTH, letters::String=LETTERS
)::Vector{String}
    subjects = Vector{String}([])
    while length(subjects) < n
        s = generate_string(subject_length, letters)
        # push s if unique
        s in subjects || push!(subjects, s)
    end
    return subjects
end

function generate_divisions(
    n::Int; grades::AbstractArray=GRADES, sections::AbstractArray=SECTIONS
)::Vector{Division}
    divisions = Vector{Division}([])
    while length(divisions) < n
        d = generate_division(grades, sections)
        # push d if unique
        d in divisions || push!(divisions, d)
    end
    return divisions
end

function generate_division(grades::AbstractArray, sections::AbstractArray)::Division
    grade = rand(grades)
    section = rand(sections)
    return Division(grade, section)
end

function generate_teachers(
    n::Int,
    subjects::Vector{String},
    divisions::Vector{Division};
    letters::String=LETTERS,
    name_length::Int=NAME_LENGTH,
    id_length::Int=ID_LENGTH,
)::Vector{Teacher}
    teachers = Vector{Teacher}([])
    while length(teachers) < n
        t = generate_teacher(
            subjects,
            divisions;
            letters=letters,
            name_length=name_length,
            id_length=id_length,
        )
        # push t if unique
        t in teachers || push!(teachers, t)
    end
    return teachers
end

function generate_teacher(
    subjects::Vector{String},
    divisions::Vector{Division};
    letters::String=LETTERS,
    name_length::Int=NAME_LENGTH,
    id_length::Int=ID_LENGTH,
)::Teacher
    # get grades from divisions
    grades = unique([d.grade for d in divisions])
    # get (random) input parameters
    name = generate_string(name_length, letters)
    id = name[1:id_length]  # slice `id` from `name`
    # id = generate_string(id_length, letters)
    somesubjects = generate_random(subjects)
    somegrades = generate_random(grades)
    # return Teacher instance
    return Teacher(name, id, somesubjects, somegrades)
end

function generate_timetables(
    n::Int,
    numperiods::Vector{Int},
    subjects::Vector{String},
    teachers::Vector{Teacher},
    divisions::Vector{Division},
)::Vector{Timetable}
    timetables = Vector{Timetable}([])
    mutable_divisions = copy(divisions)
    while length(timetables) < n
        division_i = rand(1:length(mutable_divisions))
        division = mutable_divisions[division_i]
        t = generate_timetable(numperiods, subjects, teachers, division)
        # if t is unique
        t in timetables && continue
        # push t
        push!(timetables, t)
        # remove division from mutable_divisions
        deleteat!(mutable_divisions, division_i)
    end
    return timetables
end

function generate_timetable(
    numperiods::Vector{Int},
    subjects::Vector{String},
    teachers::Vector{Teacher},
    division::Division,
)::Timetable
    someteachers = generate_random(teachers)
    teachersubjects = vcat([t.subjects for t in someteachers]...)
    subjectcounts = generate_subjectcounts(teachersubjects, numperiods)
    return Timetable(numperiods, subjectcounts, someteachers, division)
end

function generate_subjectcounts(
    subjects::Vector{String}, numperiods::Vector{Int}
)::SubjectCounts
    subjectcounts = SubjectCounts(s => 0 for s in subjects)
    for i in 1:sum(numperiods)
        # get a random subject
        s = rand(subjects)
        # increment it by 1
        subjectcounts[s] = subjectcounts[s] + 1
    end
    return subjectcounts
end

function generate_string(length::Int, letters::String)::String
    letters = split(letters, "")
    # get `length` random letters and join them
    s = join(rand(letters, (length)), "")
    return s
end

"""
    generate_random(s)

Return a random amount of random items from collection `s`.
"""
function generate_random(s)
    numitems = rand(1:length(s))
    items = rand(s, (numitems))
    return items
end

function generate_ratio(s, ratio::Float64=1.0)
    numitems = convert(Int, floor(ratio * length(s)))
    items = rand(s, (numitems))
    return items
end
