using TimetableSolver
using JuMP
using ConstraintSolver
using DataStructures: OrderedDict

# TODO: add return type for functions

const CS = ConstraintSolver

"""
    VarRefOrExpr

Represents either a model variable reference or expression reference.

Alias for union of VariableRef and AffExpr.
"""
VarRefOrExpr = Union{VariableRef,AffExpr}

#=
Each variable is a string of the form:
    `{div}_{row}_{period}_{type}`,
where div is the str representation of division,
row is the number of row, period is the number of period,
and type is either 'subject' or 'teacher'.

Each domain value represents a subject or teacher, so its value
should be a str of the form: `{subject}` or `{teacher}`.

However, all the strings are hidden and ints are used for solving directly.
Mappings are generated and stored in VariableData struct.
=#

"""
    VariableData

Immutable struct to store data related to divisions, variables and values,
and their mappings from ints to strings, because the solver only works on ints.

# Constructors
- `VariableData(schedule::Schedule)::VariableData`

Fields:
- `divvarval_maps::OrderedDict{Symbol,OrderedDict}`: Keys are a symbol `:subject` or `:teacher`.
  Values are map of ints (div) to 2-tuple of vecs of ints (var, val).
- `divvarval_mapstrs::OrderedDict{Symbol,OrderedDict}`: Same as `div_var_val_map` but with strings instead of ints.

- `alldivs::Vector{Int}`: Vector of all divs as ints.
- `allvars::Vector{Int}`: Vector of all vars as ints. (no `:subject` `:teacher` bifurcation)
- `allvals::Vector{Int}`: Vector of all vals as ints. (no `:subject` `:teacher` bifurcation)

- `divmap::OrderedDict{Int,String}`: Map from div ints to strings.
- `varmap::OrderedDict{Int,String}`: Map from variable ints to strings.
- `valmap::OrderedDict{Int,String}`: Map from values ints to strings.
- `inversedivmap::OrderedDict{String,Int}`: Inverted `divmap`.
- `inversevarmap::OrderedDict{String,Int}`: Inverted `varmap`.
- `inversevalmap::OrderedDict{String,Int}`: Inverted `valmap`.

- `schedule::Schedule`: Schedule type instance.

"""
struct VariableData
    divvarval_maps::OrderedDict{Symbol,OrderedDict}
    divvarval_mapstrs::OrderedDict{Symbol,OrderedDict}

    alldivs::Vector{Int}
    allvars::Vector{Int}
    allvals::Vector{Int}

    divmap::OrderedDict{Int,String}
    varmap::OrderedDict{Int,String}
    valmap::OrderedDict{Int,String}
    inversedivmap::OrderedDict{String,Int}
    inversevarmap::OrderedDict{String,Int}
    inversevalmap::OrderedDict{String,Int}

    schedule::Schedule

    function VariableData(schedule::Schedule)::VariableData
        # get divvarval_mapstrs
        divvarval_mapstrs = get_divvarval_mapstrs(schedule)

        # extract str representations of all data
        alldiv_strs = Vector{String}([])
        allvar_strs = OrderedDict{Symbol,Vector{String}}(
            :subject => [],
            :teacher => []
        )
        allval_strs = OrderedDict{Symbol,Vector{String}}(
            :subject => [],
            :teacher => []
        )
        # symbol is `:subject` or `:teacher`
        # symbol_map is div_var_val_map_strs but for either subject or teacher only
        for (symbol, symbolmap) in divvarval_mapstrs
            for (div_str, varval_strs) in symbolmap
                push!(alldiv_strs, div_str)
                for var_str in varval_strs[1]
                    # push the var to the proper key in all_var_strs
                    push!(allvar_strs[symbol], var_str)
                end
                for val_str in varval_strs[2]
                    # push the val to the proper key in all_var_strs
                    push!(allval_strs[symbol], val_str)
                end
            end
        end

        # remove duplicate values from allval_strs
        allval_strs[:subject] = unique(allval_strs[:subject])
        allval_strs[:teacher] = unique(allval_strs[:teacher])

        # remove duplicate values from alldiv_strs
        alldiv_strs = unique(alldiv_strs)

        # define int representations of all data
        # and int to str mappings
        alldivs = Vector{Int}(1:length(alldiv_strs))
        divmap::OrderedDict{Int,String} = OrderedDict(
            enumerate(alldiv_strs)
        )
        inversedivmap::OrderedDict{String,Int} = OrderedDict(v => k for (k, v) in divmap)

        allvars = Vector{Int}(1:(length(allvar_strs[:subject]))+length(allvar_strs[:teacher]))
        # nested list comp
        # return var_str for var_str in symbol_var_strs which are in all_var_strs
        varmap::OrderedDict{Int,String} = OrderedDict(
            enumerate([v for (_, var_strs) in allvar_strs for v in var_strs])
        )
        inversevarmap::OrderedDict{String,Int} = OrderedDict(v => k for (k, v) in varmap)

        allvals = Vector{Int}(1:(length(allval_strs[:subject]))+length(allval_strs[:teacher]))
        # nested list comp (same as for `var_map`)
        valmap::OrderedDict{Int,String} = OrderedDict(
            enumerate([v for (_, val_strs) in allval_strs for v in val_strs])
        )
        inversevalmap::OrderedDict{String,Int} = OrderedDict(v => k for (k, v) in valmap)

        # dict to store ordereddict of all vars and vals mapped to divs
        # dict keys are :subject and :teacher
        divvarval_maps::OrderedDict{Symbol,OrderedDict} = OrderedDict(
            :subject => OrderedDict(),
            :teacher => OrderedDict()
        )

        # generate values for div_var_val_map
        # symbol is `:subject` or `:teacher`
        # symbol_map is divvarval_mapstrs but for either subject or teacher only
        for (symbol, symbolmap) in divvarval_mapstrs
            for (i, (div_str, (var_strs, val_strs))) in enumerate(symbolmap)
                # int representing current div
                div::Int = inversedivmap[div_str]

                # ints representing current vars
                vars = Vector{Int}([inversevarmap[v] for v in var_strs])
                vals = Vector{Int}([inversevalmap[v] for v in val_strs])

                # add key value pair to div_var_val_map
                divvarval_maps[symbol][div] = (vars, vals)
            end
        end

        return new(
            divvarval_maps, divvarval_mapstrs,
            alldivs, allvars, allvals,
            divmap, varmap, valmap, inversedivmap, inversevarmap, inversevalmap,
            schedule
        )
    end

    function get_divvarval_mapstrs(schedule::Schedule)::OrderedDict{Symbol,OrderedDict}
        # dict to store ordereddict of all vars and vals mapped to divs
        # dict keys are :subject and :teacher
        divvarval_maps::OrderedDict{
            Symbol,OrderedDict{String,Tuple{Vector{String},Vector{String}}}
        } = OrderedDict(
            :subject => OrderedDict(),
            :teacher => OrderedDict()
        )

        # fill divvarval_maps with data
        for (div, tt) in schedule.data
            subjectvals::Vector{String} = []
            teachervals::Vector{String} = []

            # add dom vals for both teachers and subjects
            for (subject, teachers) in tt.subjectteachers
                push!(subjectvals, subject)
                for t in teachers
                    push!(teachervals, t)
                end
            end

            subjectvars::Vector{String} = []
            teachervars::Vector{String} = []

            for (i, row) in enumerate(tt.data)
                for j in (1:length(row))
                    # add subject variable
                    subject = "$(div)_$(i)_$(j)_subject"
                    push!(subjectvars, subject)
                    # add teacher variable
                    teacher = "$(div)_$(i)_$(j)_teacher"
                    push!(teachervars, teacher)
                end
            end

            # only use unique vals
            subjectvals = unique(subjectvals)
            teachervals = unique(teachervals)

            # create a key for every div, in teacher and subject
            divvarval_maps[:subject][div] = (subjectvars, subjectvals)
            divvarval_maps[:teacher][div] = (teachervars, teachervals)
        end

        return divvarval_maps
    end
end

# TODO: add kwargs arg to this and other function to pass kwargs to Model()
"""
    get_model(vardata::VariableData, timeout::Float64=Inf, all_solutions::Bool=false)::Tuple{Model,OrderedDict}

Return a JuMP model created using `vardata`, and an OrderedDict of the variables defined in the model.

# Arguments
- `vardata::VariableData`: VariableData object representing the variables and constraints to be added to the model.
- `timeout::Float64=Inf`: Float representing the maximum time to run the model.
- `all_solutions::Bool=false`: Bool representing whether to return all solutions or just the first.

# Notes
- Create a model with the correct variables, and adds constraints to the model.  
- The variables defined are anonymous, so they are stored in an OrderedDict mapped to their int representation.
"""
function get_model(vardata::VariableData, timeout::Float64 = Inf, all_solutions::Bool = false
)::Tuple{Model,OrderedDict}
    # create a constraint solver model and set ConstraintSolver as the optimizer
    m = Model(optimizer_with_attributes(CS.Optimizer,
        # logging vector containing :Info and/or :Table or empty
        "logging" => [],

        # whether to return all possible solutions
        "all_solutions" => all_solutions,

        # seed for random operations given for reproducibility
        "seed" => 0,
        # default to :Auto
        # "traverse_strategy" => :BFS,
        # "traverse_strategy"=> :DFS,
        # "traverse_strategy"=> :DBFS,

        # default :Auto
        # "branch_split"=>:Smallest,
        # "branch_split"=>:Biggest,
        # "branch_split" => :InHalf,

        "branch_strategy" => :IMPS, # default

        # simplify alldifferent, etc. constraints
        "simplify" => true, # default

        # max seconds before exiting with status `MOI.TIME_LIMIT`
        "time_limit" => timeout,

        # backtracking options
        "backtrack" => true, # default
        "backtrack_sorting" => true, # default

        # "lp_optimizer" => cbc_optimizer,
        # "lp_optimizer" => glpk_optimizer,
        # "lp_optimizer" => ipopt_optimizer,
    ))

    # define variables
    modelvars = define_variables!(m, vardata)

    # define constraints
    define_constraints!(m, modelvars, vardata)

    return m, modelvars
end

"""
    define_variables!(m::Model, vardata::VariableData)::OrderedDict{Int,VarRefOrExpr}

Define variables in the model `m` using the `vardata` object.
Return an OrderedDict mapping the int representation of the variable to the variable reference/expression reference.

# Notes
- Modify the model `m` in place.
- See [`VarRefOrExpr`](@ref).
"""
function define_variables!(
    m::Model, vardata::VariableData)::OrderedDict{Int,VarRefOrExpr}
    divvarval_maps = vardata.divvarval_maps

    # mapping variable int repr to its model variableref
    modelvars = OrderedDict{Int,VarRefOrExpr}()

    for (symbol, symbolmap) in divvarval_maps
        for (div, (vars, vals)) in symbolmap
            # define a set of vars at a time
            currentmodelvars = @variable(m, [vars], CS.Integers(vals))
            # allocate them to the value of var in modelvars one by one
            for v in vars
                modelvars[v] = currentmodelvars[v]
            end
        end
    end

    return modelvars
end

"""
    define_subjectconstraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing

Define subject constraints in the model `m` using the `vardata` object and the model variables `modelvars`.

# Notes
- Modify the model `m` in place.
"""
function define_subjectconstraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing
    schedule = vardata.schedule
    divvarval_maps = vardata.divvarval_maps
    inversedivmap = vardata.inversedivmap
    inversevalmap = vardata.inversevalmap
    for (div_str, tt) in schedule.data
        # define terms
        div = inversedivmap[div_str]
        counts = OrderedDict{Int,Int}(
            inversevalmap[subject_str] => count
            for (subject_str, count) in tt.subjectcounts
        )
        vars = divvarval_maps[:subject][div][1]
        vals = collect(Int, keys(counts))
        # tl;dr (var::Int = 2) -> (var::Binary[] = [0, 1, 0]) index shows the value
        # create a matrix of binary variables:
        # `vars` as indices and `vals` as number of values
        # so instead of setting an int as value of each var
        # each var has `vals` corresponding binary variables
        binvars = @variable(m, [vars, vals], Bin)
        # add constraint to only choose one val
        @constraint(m, [i = vars], sum(binvars[i, :]) == 1)
        # add constraint to only choose that val `counts[val]` times
        @constraint(m, [j = vals], sum(binvars[:, j]) == counts[j])
        # array of expressions that actually store the value of var as int
        exprs = @expression(m, [i = vars], sum(j * binvars[i, j] for j in vals))
        # replace the corresponding vars in modelvars with exprs
        for var in vars
            # delete the var from the model
            delete(m, modelvars[var])
            # set the var to an expr defined above
            modelvars[var] = exprs[var]
        end
    end
end

"""
    define_subjectteacherconstraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing

Define subject-teacher constraints in the model `m` using the `vardata` object and the model variables `modelvars`.

# Notes
- Modify the model `m` in place.
"""
function define_subjectteacherconstraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing
    divvarval_maps = vardata.divvarval_maps
    inversevalmap = vardata.inversevalmap
    schedule = vardata.schedule

    # mapping div to corresponding subjectteachers
    subjectteacher_maps = OrderedDict{Int,OrderedDict}()
    for (div_str, tt) in schedule.data
        div = vardata.inversedivmap[div_str]
        # subject teacher mappings as ints
        subjectteachers = OrderedDict{Int,Vector{Int}}()
        # get the subjectteacher value for this timetable
        subjectteacher_strs = tt.subjectteachers
        # convert strs to ints, and add to `subjectteachers`
        for (subject, teachers) in subjectteacher_strs
            subject_int = inversevalmap[subject]
            teacher_ints = [inversevalmap[t] for t in teachers]
            subjectteachers[subject_int] = teacher_ints
        end
        subjectteacher_maps[div] = subjectteachers

    end

    # iterate over every set of subject variables (by div)
    for (div, (subjectvars, _)) in divvarval_maps[:subject]
        # generate pairs of all possible subject teacher combinations
        # and store them in a matrix
        numpairs = sum(length.(values(subjectteacher_maps[div])))
        subjectteacherpairs = Matrix{Int}(undef, numpairs, 2)
        i = 0
        for (subject, teachers) in subjectteacher_maps[div]
            for teacher in teachers
                i += 1
                subjectteacherpairs[i, 1:2] = [subject, teacher]
            end
        end
        # add using CS.TableSet(table)
        teachervars = divvarval_maps[:teacher][div][1]
        for (svar, tvar) in zip(subjectvars, teachervars)
            # model vars corresponding to this pair of subject and teacher vars
            (modelsvar, modeltvar) = modelvars[svar], modelvars[tvar]
            @constraint(m, [modelsvar, modeltvar] in CS.TableSet(subjectteacherpairs))
        end
    end

    return nothing
end

"""
    define_teacherconstraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing

Define teacher constraints in the model `m` using the `vardata` object and the model variables `modelvars`.

# Notes
- Modify the model `m` in place.
"""
function define_teacherconstraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing
    # variables with same row,period should have different teachers
    divvarval_maps = vardata.divvarval_maps

    # following block of code creates a list of vars
    # grouped by the same row and period
    i = 0
    while true
        i += 1
        # store var or 0 if var not found
        rowperiodvars = [get(vars, i, 0) for (_, (vars, _)) in divvarval_maps[:teacher]]
        # remove zeroes from rowperiodvars
        filter!(!iszero, rowperiodvars)
        # if no vars were pushed to list,
        # then we have exceeded the number of rows and periods
        if length(rowperiodvars) == 0
            break
        end
        # now get model vars from these vars
        rowperiodmodelvars = [modelvars[x] for x in rowperiodvars]
        # add alldifferent constraint
        @constraint(m, rowperiodmodelvars in CS.AllDifferent())
    end

    return nothing
end

"""
    define_constraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing

Define all constraints in the model `m` using the `vardata` object and the model variables `modelvars`.

# Notes
- Modify the model `m` in place.
- Call [`define_subjectconstraints!`](@ref), [`define_subjectteacherconstraints!`](@ref)
  and [`define_teacherconstraints!`](@ref) internally, in the respective order.
"""
function define_constraints!(m::Model, modelvars::OrderedDict, vardata::VariableData)::Nothing
    define_subjectconstraints!(m, modelvars, vardata)

    define_subjectteacherconstraints!(m, modelvars, vardata)

    define_teacherconstraints!(m, modelvars, vardata)

    return nothing
end

"""
    get_solution(m::Model, modelvars::OrderedDict, vardata::VariableData)::Tuple{OrderedDict{Int,Int},MOI.TerminationStatusCode}

Return a solution and status code after solving the given model `m` and using model variables `modelvars` and variable data `vardata` to access the solution values.

# Notes
- Model is optimally solved only if the status code is [`MOI.OPTIMAL`](https://jump.dev/JuMP.jl/stable/moi/reference/models/#MathOptInterface.TerminationStatusCode).
- Solution is a mapping from variable to its value (both as ints).
"""
function get_solution(
    m::Model, modelvars::OrderedDict, vardata::VariableData)::Tuple{OrderedDict{Int,Int},MOI.TerminationStatusCode}
    # solve model
    optimize!(m)

    # convert model values to var=>sol mapping
    solution = OrderedDict{Int,Int}()

    # model status
    status = JuMP.termination_status(m)

    if status != MOI.OPTIMAL
        error("Model unsolved!\nstatus = $status")
    end

    for (symbol, symbolmap) in vardata.divvarval_maps
        for (div, (vars, vals)) in symbolmap
            for var in vars
                # get the corresponding var defined in the model
                mvar = modelvars[var]
                # get its value
                mval = Int(JuMP.value(mvar))
                # add var val mapping to solution
                solution[var] = mval
            end
        end
    end

    # return solution
    return solution, status
end

"""
    convertsolution(rawsolution::OrderedDict{Int,Int}, vardata::VariableData)::OrderedDict{String,String}

Return a solution in the form of a mapping from variable to its value (both as strings).

# Notes
- Convert an `Int=>Int` solution to a `String=>String` one using the `inverse*` mappings defined in `vardata`.
"""
function convertsolution(
    rawsolution::OrderedDict{Int,Int}, vardata::VariableData)::OrderedDict{String,String}
    solution = OrderedDict{String,String}()
    # iterate over every var and val in solution
    for (var, val) in rawsolution
        # get var val strs using mappings
        var_str = vardata.varmap[var]
        val_str = vardata.valmap[val]
        # add it to solution
        solution[var_str] = val_str
    end
    return solution
end

"""
    applysolution!(schedule::Schedule, solution::OrderedDict{String,String})::Nothing

Apply a solution (of strings) to the given schedule.

# Notes
- Modify the schedule in place.
"""
function applysolution!(schedule::Schedule, solution::OrderedDict{String,String})::Nothing
    # iterate over every var and val in solution
    for (var, val) in solution
        # modify schedule with var and val
        modify!(schedule, var, val)
    end
end

"""
    solve!(schedule::Schedule, timeout::Float64 = Inf, all_solutions::Bool = false)::Tuple{OrderedDict{String,String},MOI.TerminationStatusCode}

Solve a given schedule in place and return a `String=>String` solution and status code.

# Arguments
- `schedule::Schedule`: Schedule object representing the problem.
- `timeout::Float64=Inf`: Float representing the maximum time to run the model.
- `all_solutions::Bool=false`: Bool representing whether to return all solutions or just the first.

# Notes
- Schedule is optimally solved only if the status code is [`MOI.OPTIMAL`](https://jump.dev/JuMP.jl/stable/moi/reference/models/#MathOptInterface.TerminationStatusCode).
"""
function solve!(
    schedule::Schedule, timeout::Float64 = Inf, all_solutions::Bool = false
)::Tuple{OrderedDict{String,String},MOI.TerminationStatusCode}
    # get vardata
    vardata = VariableData(schedule)

    # get model and model vars
    m, modelvars = get_model(vardata, timeout, all_solutions)

    # get solution
    rawsolution, status = get_solution(m, modelvars, vardata)

    # convert solution from ints to strs
    solution = convertsolution(rawsolution, vardata)

    # apply solution
    applysolution!(schedule, solution)

    # return solution
    return solution, status
end
