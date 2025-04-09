# Homework 9

1. (Integer programming) Use the integer programming for solving the maximum independent set problem. The maximum independent set problem is a well-known NP-complete problem that asks for the largest subset of vertices in a graph such that no two vertices in the subset are connected by an edge. Hint: use an boolean variable $x_i$ to indicate whether the vertex $i$ is in the independent set.

2. (Integer programming - optional) Improve the performance of the crystal structure prediction by tuning the integer programming solver SCIP. It is highly recommended to read the thesis [^Achterberg2009] to better understand the [parameters in SCIP](https://scip.zib.de/doc/html/PARAMETERS.php). Try to get a performance improvement of at least 2x. Submit your code and a report of your tuning process.

3. (Challenge: 0-1 programming) Factorize a 350-bit number with the integer programming.
TODO: generate a random 350-bit number. Show the 60 bit demo.
Hint: This problem is also known as 0-1 programming. There are some tricks to optimize the 0-1 programming in the thesis [^Achterberg2009].
One promising direction is to combine branching and the state of the art integer programming solver, such as CPLEX and Gurobi.

[^Achterberg2009]: Achterberg, T., 2009. Constraint Integer Programming.