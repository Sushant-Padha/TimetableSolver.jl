using TimetableSolver

C9 = Division(9, 3)
D10 = Division(10, 4)

subjectcounts_C9 = SubjectCounts(
    "MATH"=>2, "ENG"=>2, "SPORTS"=>1
)
subjectcounts_D10 = SubjectCounts(
    "MATH"=>2, "ENG"=>1, "SCIENCE"=>2
)

mark = Teacher("Mark Andrews",  "MARK",     ["MATH","SCIENCE"], [9, 10])
john = Teacher("John Curry",    "JOHN",     ["MATH"],           [9])
geeta = Teacher("Geeta Gupta",  "GGA",      ["ENG"],            [9, 10])
paul = Teacher("Paul Reid",     "PAUL",     ["SPORTS"],         [9])
jane = Teacher("Jane Murphy",   "JANE",     ["SCIENCE"],        [10])

tt_C9 = Timetable(
    [3, 2],
    subjectcounts_C9,
    [mark, john, geeta, paul],
    C9
)
tt_D10 = Timetable(
    [3, 2],
    subjectcounts_D10,
    [mark, geeta, jane],
    D10
)

schedule = Schedule(tt_C9, tt_D10)

@time solution, status = solve!(schedule)
schedule
