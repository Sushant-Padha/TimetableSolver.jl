var documenterSearchIndex = {"docs":
[{"location":"tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"This is a tutorial to create your own timetables and solve them using the package.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"This assumes that you have a compatible, working Julia version installed on your system, and have a basic understanding of the language. See the For Beginners page for help.","category":"page"},{"location":"tutorial/#Installation","page":"Tutorial","title":"Installation","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"First, we must install the package.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"$ julia\n] add TimetableSolver","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Then we have to use the package with:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using TimetableSolver","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Now, everything defined in the package will available to use which can be used to model our data.","category":"page"},{"location":"tutorial/#Data","page":"Tutorial","title":"Data","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Let's create a fictional timetable with some data to represent and solve using this package.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"We have two divisions of students: 9-C, and 10-D.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"They both have a timetable for two days of a week, with 3 periods on the first day and 2 periods on the second day. So, a total of 5 periods over 2 days.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"We have 5 teachers:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Mark: teaches math and science to grades 9 and 10\nJohn: teaches math to grade 9\nGeeta: teaches english to grade 9 and 10\nPaul: teaches physical education to grade 9\nJane: teachers science to grade 10","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Grade 9-C, has 2 math periods, 2 english periods and 1 physical education period in their timetable.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Grade 10-D, has 2 math periods, 1 english period and 2 science periods in their timetable.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"To keep it simple, any teacher can teach any division as long as they are qualified for the grade (can be changed in your model).   So, Mark can teach math to division 10-D and 9-C (because he teaches grade 9 and 10) but John can only teach division 9-C.","category":"page"},{"location":"tutorial/#Modelling-Data","page":"Tutorial","title":"Modelling Data","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Now, we need to model the data for our own timetable into the language, using the types provided by the package.","category":"page"},{"location":"tutorial/#Subjects","page":"Tutorial","title":"Subjects","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"To represent a subject, just use a string. Make sure the same string is used everywhere.   To be regular, try to use all uppercase strings.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"# ! not actual code just a demo\n\"MATH\" \"ENG\"    # this is correct\n\"math\" \"eng\"    # this is also correct\n\"mATh\" \"enG\"    # this is not recommended\n:MATH ENG       # this is wrong","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Note that you can use \"ENG\" for english and \"PHYSICAL\" for physical education, but make sure that youreuse the _exact same strings later in the code.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"!!! note Declaring strings in Julia     See the String section for help.","category":"page"},{"location":"tutorial/#Subject-Counts","page":"Tutorial","title":"Subject Counts","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The SubjectCounts is used to represent an ordered dictionary of, subjects mapped to the number of times they should occur in a timetable (alias for OrderedDict{String,Int}).   So, for our data, the subject counts will look like:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"subjectcounts_C9 = SubjectCounts(\n    \"MATH\"=>2, \"ENG\"=>2, \"SPORTS\"=>1\n)\nsubjectcounts_D10 = SubjectCounts(\n    \"MATH\"=>2, \"ENG\"=>1, \"SCIENCE\"=>2\n)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"subjectcounts_C9 represents the subject counts for grade 9-C (use C9 instead of 9C read more).   subjectcounts_D10 represents the same about grade 10-D.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"!!! note Using dictionaries in Julia     See the Dictionary section for help.","category":"page"},{"location":"tutorial/#Division","page":"Tutorial","title":"Division","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The Division type is used to represent a division of students. It stores two fields: grade and section (both integers).   For our data, the divisions can be represented as:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"C9 = Division(9, 3)\nD10 = Division(10, 4)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"warning: Naming a division variable\nWhen you create a division variable, try naming it with the section first, i.e., C9 instead of 9C.   Declaring variables starting with a number is not recommended and can lead to unintended consequences.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"!!! note Using type instances in Julia     See the Type Instances section for help.","category":"page"},{"location":"tutorial/#Teacher","page":"Tutorial","title":"Teacher","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The Teacher type is used to represent a teacher with all of the data related to them. To create a Teacher instance, pass the following arguments (example from #Data for teacher Mark):","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Name: \"Mark Andrews\", string representing the name of the teacher, can be anything you want it does not affect the model in any way\nId: \"MARK\", string representing the id of the teacher, this is the id that is used by the model.  This is the string that is returned at the end when the model is solved. Try to use all uppercase letters, and keep the id's short.\nSubjects: [\"MATH\",\"SCIENCE\"], a list of all subjects that the teacher can teach\nGrades: [9,10], a list of all grades that a teacher can teach [1]","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"For the full data, all the teachers can be represented by:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"mark = Teacher(\"Mark Andrews\",  \"MARK\",     [\"MATH\",\"SCIENCE\"], [9, 10])\njohn = Teacher(\"John Curry\",    \"JOHN\",     [\"MATH\"],           [9])\ngeeta = Teacher(\"Geeta Gupta\",  \"GGA\",      [\"ENG\"],            [9, 10])\npaul = Teacher(\"Paul Reid\",     \"PAUL\",     [\"SPORTS\"],         [9])\njane = Teacher(\"Jane Murphy\",   \"JANE\",     [\"SCIENCE\"],        [10])","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Note that mark now represents a teacher instance, with all the data added. \"MARK\" is just a string representing his id, that will be used for solving and displaying the solution.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"!!! note Using lists in Julia     See the List section for help.","category":"page"},{"location":"tutorial/#Period","page":"Tutorial","title":"Period","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The Period type is used represent a single period in one day of a timetable. It stores two fields: the subject (being taught) and the teacher (teaching the subject).","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"You won't have to use this in the code as it is only referenced internally, so you do not need to use or define it.","category":"page"},{"location":"tutorial/#Timetable","page":"Tutorial","title":"Timetable","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The Timetable type is used to represent the actual timetable for a division.   To create a Timetable instance, pass the following arguments (examples from #Data for grade 9-C):","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Number of Periods: [3, 2], 3 periods on the first day and 2 periods on the second day\nSubject Counts: subjectcounts_C9, defined in #Subject Counts\nTeachers: [mark, john, geeta, paul], a list of some of the teachers we defined in #Teacher.   jane is not added because she teaches science which is not a valid subject for grade 9. We can add her to the list, but it won't affect anything or be of any use.   Do note however, that we have added mark as a teacher even though john already is added (both teach math). This is done so that in case a conflict arises, where john cannot teach this division because he has a period in another one, mark can teach for that period in the model.   In our case, this won't happen due to the simplicity of the model, but in bigger problems, this should be used to make solving easier.\nDivision: C9, the division representing 9-C we defined in #Division","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"For the full data, all the timetables can be represented by:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"tt_C9 = Timetable(\n    [3, 2],\n    subjectcounts_C9,\n    [mark, john, geeta, paul],\n    C9\n)\ntt_D10 = Timetable(\n    [3, 2],\n    subjectcounts_D10,\n    [mark, geeta, jane],\n    D10\n)","category":"page"},{"location":"tutorial/#Schedule","page":"Tutorial","title":"Schedule","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The Schedule type is used to represent a full schedule of all timetables. This is the most high level type in the package. You should only create one schedule for a problem (schedule is synonymous with model here), and add all your timetables to it.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"For our data, the schedule will be created as:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"schedule = Schedule(tt_C9, tt_D10)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"[1]: Division represents a group of students studying together. It is a combination of a grade and a section. So, 9-C and 9-D are different divisions, but have the same grade.   Grade is just the level at which the students study, like grade 10, 11. It is represented by a simple integer where needed.","category":"page"},{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"","category":"page"},{"location":"reference/solver/#Solver","page":"Solver","title":"Solver","text":"","category":"section"},{"location":"reference/solver/","page":"Solver","title":"Solver","text":"Modules = [TimetableSolver]\nPages   = [\"solver.jl\"]","category":"page"},{"location":"reference/solver/#TimetableSolver.VariableData","page":"Solver","title":"TimetableSolver.VariableData","text":"VariableData\n\nImmutable struct to store data related to divisions, variables and values, and their mappings from ints to strings.\n\nBecause the solver only works on ints.\n\nFields:\n\ndivvarval_maps::OrderedDict{Symbol,OrderedDict}:\n\nKeys are a symbol :subject or :teacher`. Values are map of ints (div)  to 2-tuple of vecs of ints (var, val).\n\ndivvarval_mapstrs::OrderedDict{Symbol,OrderedDict}:\n\nSame as div_var_val_map but with strings instead of ints.\n\nalldivs::Vector{Int}: Vector of all divs as ints.\nallvars::Vector{Int}: Vector of all vars as ints. (no :subject :teacher bifurcation)\nallvals::Vector{Int}: Vector of all vals as ints. (no :subject :teacher bifurcation)\ndivmap::OrderedDict{Int,String}: Map from div ints to strings.\nvarmap::OrderedDict{Int,String}: Map from variable ints to strings.\nvalmap::OrderedDict{Int,String}: Map from values ints to strings.\ninversedivmap::OrderedDict{String,Int}: Inverted divmap.\ninversevarmap::OrderedDict{String,Int}: Inverted varmap.\ninversevalmap::OrderedDict{String,Int}: Inverted valmap.\nschedule::Schedule: Schedule type instance.\n\n\n\n\n\n","category":"type"},{"location":"explanation/#Explanation","page":"Explanation","title":"Explanation","text":"","category":"section"},{"location":"explanation/","page":"Explanation","title":"Explanation","text":"Explanation of some of the internal code.","category":"page"},{"location":"reference/types/#Types","page":"Types","title":"Types","text":"","category":"section"},{"location":"reference/types/","page":"Types","title":"Types","text":"Modules = [TimetableSolver]\nPages   = [\"types.jl\"]","category":"page"},{"location":"beginner/#For-Beginners","page":"For Beginners","title":"For Beginners","text":"","category":"section"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"Information and links for people new to Julia or new to programming in general.","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"Assumes you have some basic knowledge of programming like variables, types, control flow, functions, using a terminal.","category":"page"},{"location":"beginner/#Julia-Installation","page":"For Beginners","title":"Julia Installation","text":"","category":"section"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"Download Julia v1.6 from here for your OS and architecture.","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"While installing make sure to choose Add To PATH.","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"Once finished, open up a terminal and run julia --version to make sure you get an output that matches \"julia version 1.6.x\" (may be any number in place of x).","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"If you don't get an output or a different one, please go through the steps again and install the correct version.","category":"page"},{"location":"beginner/#String","page":"For Beginners","title":"String","text":"","category":"section"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"A string is defined in Julia by encasing it in double quotes (\").   So, \"hello\" is a string, but hello or 'hello' are not. Read more.","category":"page"},{"location":"beginner/#Dictionary","page":"For Beginners","title":"Dictionary","text":"","category":"section"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"A dictionary is a list of key-value pairs.   Lets say Alice has 10 chocolates and Bob has 7. This information can be represented in a dictionary like:","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"chocolates = Dict(\"Alice\"=>10, \"Bob\"=>7)","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"Read more.","category":"page"},{"location":"beginner/#List","page":"For Beginners","title":"List","text":"","category":"section"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"A list is a collection of values. Also called an array or a vector, a list keeps the order of items. Lists are defined using square brackets ([ and ]) and seperating items with commas. For example:","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"someprimes = [2, 3, 5, 7, 11]","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"Read more.","category":"page"},{"location":"beginner/#Type-Instances","page":"For Beginners","title":"Type Instances","text":"","category":"section"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"A type of is a form of structured data. It is like a blueprint to store some information using.   To actually use that blueprint and store some real data, we need to create a type instance.   In other words, a variable that stores data as instructed by the type.","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"In Julia, you create an instance of a type, i.e., use a type like this:","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"myvariable = MyType(1, \"a string\", [1,2,3])","category":"page"},{"location":"beginner/","page":"For Beginners","title":"For Beginners","text":"As you can see, we pass it different values that are then stored in it.   The exact syntax that you have to follow and the kind of values you have to give depends on the type.","category":"page"},{"location":"how_to/#How-To","page":"How-To","title":"How To","text":"","category":"section"},{"location":"how_to/","page":"How-To","title":"How-To","text":"A quick and simple way to get started.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = TimetableSolver","category":"page"},{"location":"#TimetableSolver","page":"Home","title":"TimetableSolver","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for TimetableSolver.","category":"page"},{"location":"","page":"Home","title":"Home","text":"See the following pages:","category":"page"},{"location":"","page":"Home","title":"Home","text":"For Beginners: Information and links for people new to Julia or new to programming in general.\nTutorial: A simple tutorial to create a full model.\nHow-To: A quick and simple way to get started.\nExplanation: Explanation of some of the internal code.\nReference: Source code docs.","category":"page"}]
}
