# Homework

1. Using integer programming (IP) for solving the maximum independent set problem. Pass the following test:
```julia
using ProblemReductions, Graphs, Test

problem = IndependentSet(smallgraph(:petersen))
mis_size, mis = solve_mis_ip(problem) # implement this function with IP

@test mis_size == 4
@test is_independent_set(problem, mis)
```
