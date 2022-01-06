# For Beginners

Information and links for people new to Julia or new to programming in general.

Assumes you have some basic knowledge of programming like variables, types, control flow, functions, using a terminal.

## Julia Installation

Download Julia v1.6 from [here](https://julialang.org/downloads/) for your OS and architecture.

While installing make sure to choose `Add To PATH`.

Once finished, open up a terminal and run `julia --version` to make sure you get an output that matches `"julia version 1.6.x"` (may be any number in place of x).

If you don't get an output or a different one, please go through the steps again and install the correct version.

## String
A string is defined in Julia by encasing it in double quotes (").  
So, `"hello"` is a string, but `hello` or `'hello'` are not. [Read more](https://docs.julialang.org/en/v1/manual/strings/#String-Basics).

## Dictionary
A dictionary is a list of key-value pairs.  
Lets say Alice has 10 chocolates and Bob has 7. This information can be represented in a dictionary like:
```julia
chocolates = Dict("Alice"=>10, "Bob"=>7)
```
[Read more](https://docs.julialang.org/en/v1/base/collections/#Dictionaries).

## List
A list is a collection of values. Also called an array or a vector, a list keeps the order of items.
Lists are defined using square brackets (`[` and `]`) and seperating items with commas.
For example:
```julia
someprimes = [2, 3, 5, 7, 11]
```
[Read more](https://docs.julialang.org/en/v1/manual/arrays/#man-array-literals).

## Type Instances
A type of is a form of structured data. It is like a blueprint to store some information using.  
To actually use that blueprint and store some real data, we need to create a type instance.  
In other words, a variable that stores data as instructed by the type.

In Julia, you create an instance of a type, i.e., use a type like this:
```julia
myvariable = MyType(1, "a string", [1,2,3])
```
As you can see, we pass it different values that are then stored in it.  
The exact syntax that you have to follow and the kind of values you have to give depends on the type.
