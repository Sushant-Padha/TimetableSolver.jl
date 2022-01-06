# Tutorial

This is a tutorial to create your own timetables and solve them using the package.

This assumes that you have a compatible, working Julia version installed on your system, and have a basic understanding of the language. See the [For Beginners](./beginner.html) page for help.

## Installation

First, we must install the package.

```
$ julia
] add TimetableSolver
```

Then we have to use the package with:

```
using TimetableSolver
```

Now, everything defined in the package will available to use which can be used to model our data.

## Data

Let's create a fictional timetable with some data to represent and solve using this package.

We have two divisions of students: 9-C, and 10-D.

They both have a timetable for two days of a week, with 3 periods on the first day and 2 periods on the second day. So, a total of 5 periods over 2 days.

We have 5 teachers:
- Mark: teaches math and science to grades 9 and 10
- John: teaches math to grade 9
- Geeta: teaches english to grade 9 and 10
- Paul: teaches physical education to grade 9
- Jane: teachers science to grade 10

Grade 9-C, has 2 math periods, 2 english periods and 1 physical education period in their timetable.

Grade 10-D, has 2 math periods, 1 english period and 2 science periods in their timetable.

To keep it simple, any teacher can teach any division as long as they are qualified for the grade (can be changed in your model).  
So, Mark can teach math to division 10-D and 9-C (because he teaches grade 9 and 10) but John can only teach division 9-C.

## Modelling Data

Now, we need to model the data for our own timetable into the language, using the types provided by the package.

### Subjects

To represent a subject, just use a string. Make sure the same string is used everywhere.  
To be regular, try to use all uppercase strings.

```julia
# ! not actual code just a demo
"MATH" "ENG"    # this is correct
"math" "eng"    # this is also correct
"mATh" "enG"    # this is not recommended
:MATH ENG       # this is wrong
```
Note that you can use `"ENG"` for english and `"PHYSICAL"` for physical education, but make sure that you_reuse the _exact same_ strings later in the code.

!!! note Declaring strings in Julia
    See the [String](./beginner.html#String) section for help.
    

### Subject Counts

The `SubjectCounts` is used to represent an ordered dictionary of, subjects mapped to the number of times they should occur in a timetable (alias for `OrderedDict{String,Int}`).  
So, for our data, the subject counts will look like:
```julia
subjectcounts_C9 = SubjectCounts(
    "MATH"=>2, "ENG"=>2, "SPORTS"=>1
)
subjectcounts_D10 = SubjectCounts(
    "MATH"=>2, "ENG"=>1, "SCIENCE"=>2
)
```
`subjectcounts_C9` represents the subject counts for grade 9-C (use `C9` instead of `9C` [read more](#division)).  
`subjectcounts_D10` represents the same about grade 10-D.

!!! note Using dictionaries in Julia
    See the [Dictionary](./beginner.html#Dictionary) section for help.

### Division

The `Division` type is used to represent a division of students.
It stores two fields: grade and section (both integers).  
For our data, the divisions can be represented as:
```julia
C9 = Division(9, 3)
D10 = Division(10, 4)
```
!!! warning "Naming a division variable"
    When you create a division variable, try naming it with the section first, i.e., `C9` instead of `9C`.  
    Declaring variables starting with a number is not recommended and can lead to unintended consequences.

!!! note Using type instances in Julia
    See the [Type Instances](./beginner.html#Type-Instances) section for help.

### Teacher

The `Teacher` type is used to represent a teacher with all of the data related to them.
To create a `Teacher` instance, pass the following arguments (example from [#Data](#data) for teacher Mark):
- **Name**: `"Mark Andrews"`, string representing the name of the teacher, can be anything you want it does not affect the model in any way
- **Id**: `"MARK"`, string representing the id of the teacher, this is the id that is used by the model. 
  This is the string that is returned at the end when the model is solved. Try to use all uppercase letters, and keep the id's short.
- **Subjects**: `["MATH","SCIENCE"]`, a list of all subjects that the teacher can teach
- **Grades**: `[9,10]`, a list of all grades that a teacher can teach [^1]

For the full data, all the teachers can be represented by:
```julia
mark = Teacher("Mark Andrews",  "MARK",     ["MATH","SCIENCE"], [9, 10])
john = Teacher("John Curry",    "JOHN",     ["MATH"],           [9])
geeta = Teacher("Geeta Gupta",  "GGA",      ["ENG"],            [9, 10])
paul = Teacher("Paul Reid",     "PAUL",     ["SPORTS"],         [9])
jane = Teacher("Jane Murphy",   "JANE",     ["SCIENCE"],        [10])
```
Note that `mark` now represents a teacher instance, with all the data added. `"MARK"` is just a string representing his id, that will be used for solving and displaying the solution.

!!! note Using lists in Julia
    See the [List](./beginner.html#List) section for help.


### Period

The `Period` type is used represent a single period in one day of a timetable.
It stores two fields: the subject (being taught) and the teacher (teaching the subject).

You won't have to use this in the code as it is only referenced internally, so you do not need to use or define it.

### Timetable

The `Timetable` type is used to represent the actual timetable for a division.  
To create a `Timetable` instance, pass the following arguments (examples from [#Data](#data) for grade 9-C):
- **Number of Periods**: `[3, 2]`, 3 periods on the first day and 2 periods on the second day
- **Subject Counts**: `subjectcounts_C9`, defined in [#Subject Counts](#subject-counts)
- **Teachers**: `[mark, john, geeta, paul]`, a list of _some_ of the teachers we defined in [#Teacher](#teacher).  
  `jane` is not added because she teaches science which is not a valid subject for grade 9. We can add her to the list, but it won't affect anything or be of any use.  
  Do note however, that we have added `mark` as a teacher even though `john` already is added (both teach math). This is done so that in case a conflict arises, where `john` cannot teach this division because he has a period in another one, `mark` can teach for that period in the model.  
  In our case, this won't happen due to the simplicity of the model, but in bigger problems, this should be used to make solving easier.
- **Division**: `C9`, the division representing 9-C we defined in [#Division](#division)

For the full data, all the timetables can be represented by:
```julia
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
```

### Schedule

The `Schedule` type is used to represent a full schedule of all timetables. This is the most high level type in the package.
You should only create one schedule for a problem (schedule is synonymous with model here), and add all your timetables to it.

For our data, the schedule will be created as:
```julia
schedule = Schedule(tt_C9, tt_D10)
```

---

[^1]: Division represents a group of students studying together. It is a combination of a grade and a section. So, 9-C and 9-D are different divisions, but have the same grade.  
    Grade is just the level at which the students study, like grade 10, 11. It is represented by a simple integer where needed.
