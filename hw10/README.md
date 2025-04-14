# Homework 10
1. (Automatic differentiation) Use `FiniteDifferences.jl`, `ForwardDiff.jl` and `Enzyme.jl` to compute the gradient of the following function:
    ```julia
    function f(x)
        return sqrt(sum(x.^2))
    end
    ```

2. (Reverse mode AD - Optional) Show the following graph $G=(V, E)$ has a unit-disk embedding.
```
V = 1, 2, ..., 10
E = [(1, 2), (1, 3),
	(2, 3), (2, 4), (2, 5), (2, 6),
	(3, 5), (3, 6), (3, 7),
	(4, 5), (4, 8),
	(5, 6), (5, 8), (5, 9),
	(6, 7), (6, 8), (6, 9),
	(7,9), (8, 9), (8, 10), (9, 10)]
```
unit-disk embedding is a mapping from the vertices to a 2D space, where the distance between any two connected vertices is less than 1, and the distance between any two disconnected vertices is greater than 1.
Hint: Assign each vertex a coordinate, create a loss function to punish the violation of the unit-disk constraint, and use an Enzyme.jl + Optim.jl to minimize the loss function.

3. (Challenge) Extended the treeverse algorithm to non-uniform programs.
In the treeverse algorithm, we assume that the program is uniform, i.e., each step has the same state size and the same computing time.
However, in practice, the program may be non-uniform, i.e., when contracting a tensor network.
A non-uniform program can be described as a sequence of tuples of $(t_i, s_i)$, each containing a time cost $t_i$ and a state size $s_i$.

Please use integer programming (or other methods) to find the optimal schedule for a given non-uniform program with $1000$ steps.
