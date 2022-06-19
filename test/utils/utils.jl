"""
    israngelike(vec::AbstractVector)::Bool

Return `true` if the vector is a range-like vector, `false` otherwise.
"""
function israngelike(vec::AbstractVector)::Bool
    interval = vec[2] - vec[1]
    for i in 2:length(vec)
        new_interval = vec[i] - vec[i - 1]
        if new_interval != interval
            return false
        end
    end
    return true
end

"""
    get_printinfo(prefix::String="", prefix_arr::Vector=[""])::Function

Return closure function that prints a string with the given prefix. `prefix_arr` is used
for internal state and should be untouched.
Returned function can also be used to add more prefixes recursively, or pop last prefix.

The returned function is:
`(s::String=""; prefix::String="", pop::Bool=false)`: print the given string with pre
defined prefix, and return function with this new prefix; pop last prefix if `pop` is
`true`.

# Note

  - The first returned function is the _only_ function, i.e., when `prefix` or `pop` arguments
    are provided they modify the internal state of the called function itself.
    The same function is also returned but not needed.
  - Adding new prefix takes effect in next call.
  - Popping last prefix takes effect in current call.

This function is used to create `printinfo` functions, than can be used inside tests.
Using prefixes like "│ ", we can create framed output that is easier to inspect.

# Examples

Print repl-like output (`repl>` lines are actually printed output not an actual
repl prompt):

```jldoctest
julia> replprint = get_printinfo("repl> ")
(::var"#printinfo#13"{var"#printinfo#10#14"{Vector{String}}}) (generic function with 2 methods)

julia> replprint("@time somefunc(arg1, arg2)")
repl> @time somefunc(arg1, arg2)
(::var"#printinfo#13"{var"#printinfo#10#14"{Vector{String}}}) (generic function with 2 methods)

julia> timereplprint = replprint(; prefix="@time ")  # `replprint` itself is also modified
(::var"#printinfo#13"{var"#printinfo#10#14"{Vector{String}}}) (generic function with 2 methods)

julia> timereplprint("somefunc(arg1, arg2)")
repl> @time somefunc(arg1, arg2)
(::var"#printinfo#13"{var"#printinfo#10#14"{Vector{String}}}) (generic function with 2 methods)

julia> whichreplprint = timereplprint("somefunc(arg1, arg2)"; prefix="@which ", pop=true)
# new prefix takes effect in next call, but pop takes effect in current one

julia> timereplprint("somefunc(arg1, arg2)")  # `timereplprint` itself was also modified
repl> somefunc(arg1, arg2)
(::var"#printinfo#13"{var"#printinfo#10#14"{Vector{String}}}) (generic function with 2 methods)

julia> whichreplprint("somefunc(arg1, arg2)")
repl> @which somefunc(arg1, arg2)
(::var"#printinfo#13"{var"#printinfo#10#14"{Vector{String}}}) (generic function with 2 methods)
```

# See also

SO question on closures: https://stackoverflow.com/a/59924678/15083607
"""
function get_printinfo(prefix::String="", prefix_arr::Vector=[""])::Function
    if prefix != ""
        push!(prefix_arr, prefix)
    end
    function printinfo(s::String=""; prefix::String="", pop::Bool=false)::Function
        if pop
            pop!(prefix_arr)
        end
        if s != ""
            fprefix = join(prefix_arr, "")
            # print all lines of `s`, prefix with `fprefix`
            for line in split(s, "\n")
                print(fprefix)
                println(line)
            end
        end
        return get_printinfo(prefix, prefix_arr)
    end
    return printinfo
end
