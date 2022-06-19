using Test
using TimetableSolver
using ConstraintSolver
using JuMP

# include data
include("./data.jl")
# include utilities
include("./utils/random.jl")
include("./utils/utils.jl")

# use `printinfo` for printing info
# define `printinfo` once, modify many
printinfo = get_printinfo("  ")

@testset "VariableData" begin
    printinfo("┌ Testing `VariableData`..."; prefix="│ ")

    @testset "specific" begin
        printinfo("┌ Testing specific values..."; prefix="│ ")

        @test VARDATA.divvarval_maps == VARDATA_divvarval_maps
        @test VARDATA.divvarval_mapstrs == VARDATA_divvarval_mapstrs
        @test VARDATA.alldivs == VARDATA_alldivs
        @test VARDATA.allvars == VARDATA_allvars
        @test VARDATA.allvals == VARDATA_allvals
        @test VARDATA.divmap == VARDATA_divmap
        @test VARDATA.varmap == VARDATA_varmap
        @test VARDATA.valmap == VARDATA_valmap
        @test VARDATA.inversedivmap == VARDATA_inversedivmap
        @test VARDATA.inversevarmap == VARDATA_inversevarmap
        @test VARDATA.inversevalmap == VARDATA_inversevalmap
        @test VARDATA.schedule == VARDATA_schedule

        printinfo("└ Done."; pop=true)
    end
    @testset "general" begin
        printinfo(
            "┌ Testing general values with random schedules..."; prefix="│ "
        )

        function test_random_schedules(
            nums::Vector{Int}, numperiods::Vector{Int}, iterations::Int
        )
            for i in 1:iterations
                schedule = generate_schedule(nums, numperiods)
                @debug "schedule =\n$schedule"
                test_schedule(schedule)
            end
        end
        function test_schedule(schedule)
            printinfo("Running `test_schedule`")
            vardata = VariableData(schedule)
            ### EXTRACT TERMS FOR READABILITY
            divvarval_maps = vardata.divvarval_maps
            divvarval_mapstrs = vardata.divvarval_mapstrs
            alldivs = vardata.alldivs
            allvars = vardata.allvars
            allvals = vardata.allvals
            divmap = vardata.divmap
            varmap = vardata.varmap
            valmap = vardata.valmap
            inversedivmap = vardata.inversedivmap
            inversevarmap = vardata.inversevarmap
            inversevalmap = vardata.inversevalmap
            ### ITERATE OVER EVERY SYMBOL AND ITS VALUE
            maxdiv, maxvar, maxval = 1, 1, 1
            for (symbol, symbolmap) in divvarval_maps
                # check that symbol is either `:subject` or `:teacher`
                @test symbol in [:subject, :teacher]
                # get value for strings
                symbolmapstrs = divvarval_mapstrs[symbol]
                # zip int map and string map for testing
                for (pair, pair_str) in zip(symbolmap, symbolmapstrs)
                    # unpack into readable values
                    (div, (vars, vals)) = pair
                    (div_str, (var_strs, val_strs)) = pair_str
                    # TEST MAPPINGS
                    # AND SET `max*` VALUES
                    # test div is correctly mapped
                    @test div_str == divmap[div]
                    @test div == inversedivmap[div_str]
                    maxdiv = (div > maxdiv) ? div : maxdiv
                    # test vars are correctly mapped
                    for (int, str) in zip(vars, var_strs)
                        @test str == varmap[int]
                        @test int == inversevarmap[str]
                        maxvar = (int > maxvar) ? int : maxvar
                    end
                    # test vals are correctly mapped
                    for (int, str) in zip(vals, val_strs)
                        @test str == valmap[int]
                        @test int == inversevalmap[str]
                        maxval = (int > maxval) ? int : maxval
                    end
                end
            end
            # TEST `all*` ARE RANGE-LIKE
            @test israngelike(alldivs)
            @test israngelike(allvars)
            @test israngelike(allvals)
            # TEST MAX VALUES
            @test maxdiv == last(alldivs)
            @test maxvar == last(allvars)
            @test maxval == last(allvals)
        end

        # small values
        nums1, numperiods1, iterations1 = [5, 5, 2], [3, 2], 2
        test_random_schedules(nums1, numperiods1, iterations1)
        # big values
        nums2, numperiods2, iterations2 = [10, 10, 4], [5, 5, 3], 1
        test_random_schedules(nums2, numperiods2, iterations2)

        printinfo("└ Done."; pop=true)
    end
    printinfo("└ Done.", pop=true)
end
@testset "Model" begin
    printinfo("┌ Testing `Model`..."; prefix="│ ")

    function test_schedule(schedule::Schedule)
        ### SOLVE SCHEDULE
        solution, status = solve!(schedule)
        # check if it was solved optimally
        if status != MOI.OPTIMAL
            error("Schedule could not be solved (status=$(status)).")
        end
        ### TEST OVER TIMETABLES
        for (div, tt) in schedule.data
            # number of subjects taught has to be equal to the number of periods
            @test sum(values(tt.subjectcounts)) == sum(tt.numperiods)
            ### TEST OVER PERIODS
            for row in tt.data
                for period in row
                    # the teacher must be qualified to teach this subject
                    @test string(period.teacher) in tt.subjectteachers[period.subject]
                    @test period.subject in period.teacher.subjects
                end
            end
        end
    end

    test_schedule(SCHEDULE)

    printinfo("└ Done.", pop=true)
end
