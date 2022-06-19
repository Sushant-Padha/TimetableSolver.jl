using TimetableSolver
using DataStructures: OrderedDict

# DATA USED IN TESTS

#region basic definitions
C9 = Division(9, 3)
D10 = Division(10, 4)

SUBJECTCOUNTS_C9 = SubjectCounts("MATH" => 2, "ENG" => 2, "SPORTS" => 1)
SUBJECTCOUNTS_D10 = SubjectCounts("MATH" => 2, "ENG" => 1, "SCIENCE" => 2)

MARK = Teacher("Mark Andrews", "MARK", ["MATH", "SCIENCE"], [9, 10])
JOHN = Teacher("John Curry", "JOHN", ["MATH"], [9])
GEETA = Teacher("Geeta Gupta", "GGA", ["ENG"], [9, 10])
PAUL = Teacher("Paul Reid", "PAUL", ["SPORTS"], [9])
JANE = Teacher("Jane Murphy", "JANE", ["SCIENCE"], [10])

TT_C9 = Timetable([3, 2], SUBJECTCOUNTS_C9, [MARK, JOHN, GEETA, PAUL], C9)
TT_D10 = Timetable([3, 2], SUBJECTCOUNTS_D10, [MARK, GEETA, JANE], D10)

SCHEDULE = Schedule(TT_C9, TT_D10)

VARDATA = VariableData(SCHEDULE)

MODEL, MODELVARS = get_model(VARDATA)

RAWSOLUTION, STATUS = get_solution(MODEL, MODELVARS, VARDATA)
#endregion

#region expected values
VARDATA_divvarval_maps = OrderedDict(
    :subject => OrderedDict(
        1 => ([1, 2, 3, 4, 5], [1, 2, 3]),
        2 => ([6, 7, 8, 9, 10], [1, 2, 4]),
    ),
    :teacher => OrderedDict(
        1 => ([11, 12, 13, 14, 15], [5, 6, 7, 8]),
        2 => ([16, 17, 18, 19, 20], [5, 7, 9]),
    ),
)
VARDATA_divvarval_mapstrs = OrderedDict(
    :subject => OrderedDict(
        "9-C" => (
            [
                "9-C_1_1_subject",
                "9-C_1_2_subject",
                "9-C_1_3_subject",
                "9-C_2_1_subject",
                "9-C_2_2_subject",
            ],
            ["MATH", "ENG", "SPORTS"],
        ),
        "10-D" => (
            [
                "10-D_1_1_subject",
                "10-D_1_2_subject",
                "10-D_1_3_subject",
                "10-D_2_1_subject",
                "10-D_2_2_subject",
            ],
            ["MATH", "ENG", "SCIENCE"],
        ),
    ),
    :teacher => OrderedDict(
        "9-C" => (
            [
                "9-C_1_1_teacher",
                "9-C_1_2_teacher",
                "9-C_1_3_teacher",
                "9-C_2_1_teacher",
                "9-C_2_2_teacher",
            ],
            ["MARK", "JOHN", "GGA", "PAUL"],
        ),
        "10-D" => (
            [
                "10-D_1_1_teacher",
                "10-D_1_2_teacher",
                "10-D_1_3_teacher",
                "10-D_2_1_teacher",
                "10-D_2_2_teacher",
            ],
            ["MARK", "GGA", "JANE"],
        ),
    ),
)
VARDATA_alldivs = [1, 2]
VARDATA_allvars = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
VARDATA_allvals = [1, 2, 3, 4, 5, 6, 7, 8, 9]
VARDATA_divmap = OrderedDict(1 => "9-C", 2 => "10-D")
VARDATA_varmap = OrderedDict(1 => "9-C_1_1_subject", 2 => "9-C_1_2_subject", 3 => "9-C_1_3_subject", 4 => "9-C_2_1_subject", 5 => "9-C_2_2_subject", 6 => "10-D_1_1_subject", 7 => "10-D_1_2_subject", 8 => "10-D_1_3_subject", 9 => "10-D_2_1_subject", 10 => "10-D_2_2_subject", 11 => "9-C_1_1_teacher", 12 => "9-C_1_2_teacher", 13 => "9-C_1_3_teacher", 14 => "9-C_2_1_teacher", 15 => "9-C_2_2_teacher", 16 => "10-D_1_1_teacher", 17 => "10-D_1_2_teacher", 18 => "10-D_1_3_teacher", 19 => "10-D_2_1_teacher", 20 => "10-D_2_2_teacher")
VARDATA_valmap = OrderedDict(1 => "MATH", 2 => "ENG", 3 => "SPORTS", 4 => "SCIENCE", 5 => "MARK", 6 => "JOHN", 7 => "GGA", 8 => "PAUL", 9 => "JANE")
VARDATA_inversedivmap = OrderedDict("9-C" => 1, "10-D" => 2)
VARDATA_inversevarmap = OrderedDict("9-C_1_1_subject" => 1, "9-C_1_2_subject" => 2, "9-C_1_3_subject" => 3, "9-C_2_1_subject" => 4, "9-C_2_2_subject" => 5, "10-D_1_1_subject" => 6, "10-D_1_2_subject" => 7, "10-D_1_3_subject" => 8, "10-D_2_1_subject" => 9, "10-D_2_2_subject" => 10, "9-C_1_1_teacher" => 11, "9-C_1_2_teacher" => 12, "9-C_1_3_teacher" => 13, "9-C_2_1_teacher" => 14, "9-C_2_2_teacher" => 15, "10-D_1_1_teacher" => 16, "10-D_1_2_teacher" => 17, "10-D_1_3_teacher" => 18, "10-D_2_1_teacher" => 19, "10-D_2_2_teacher" => 20)
VARDATA_inversevalmap = OrderedDict("MATH" => 1, "ENG" => 2, "SPORTS" => 3, "SCIENCE" => 4, "MARK" => 5, "JOHN" => 6, "GGA" => 7, "PAUL" => 8, "JANE" => 9)
VARDATA_schedule = SCHEDULE
#endregion
