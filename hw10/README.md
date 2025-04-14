# Homework 10
1. (Automatic differentiation) Use `FiniteDifferences.jl`, `ForwardDiff.jl` and `Enzyme.jl` to compute the gradient of the following function:
    ```julia
    function poor_besselj(ν, z::T; atol=eps(T)) where T
        k = 0
        s = (z/2)^ν / factorial(ν)
        out = s
        while abs(s) > atol
            k += 1
            s *= (-1) / k / (k+ν) * (z/2)^2
            out += s
        end
        out
    end
    z = 2.0
    ν = 2
    # obtain the gradient on z w.r.t the output
    ```

2. (Reverse mode AD - Optional) Show the following graph $G=(V, E)$ has a unit-disk embedding.
	```julia
	vertices = collect(1:10)
	edges = [(1, 2), (1, 3),
		(2, 3), (2, 4), (2, 5), (2, 6),
		(3, 5), (3, 6), (3, 7),
		(4, 5), (4, 8),
		(5, 6), (5, 8), (5, 9),
		(6, 7), (6, 8), (6, 9),
		(7,9), (8, 9), (8, 10), (9, 10)]
	```
    Unit-disk embedding is a mapping from the vertices to a 2D space, where the distance between any two connected vertices is less than 1, and the distance between any two disconnected vertices is greater than 1.

    **Hint:** Assign each vertex a coordinate, create a loss function to punish the violation of the unit-disk constraint, and use an Enzyme.jl + Optim.jl to minimize the loss function.

4. (Challenge) Extended the treeverse algorithm[^Griewank1992] to non-uniform programs.
In the treeverse algorithm, we assume that the program is uniform, i.e., each step has the same state size and the same computing time.
However, in practice, the program may be non-uniform, i.e., when contracting a tensor network.
A non-uniform program can be described as a sequence of tuples of $(t_i, s_i)$, each containing a time cost $t_i$ and a state size $s_i$.

   **Task:** Please use integer programming (or other methods) to find the optimal checkpointing schedule for a given non-uniform program with $1000$ steps.

   **Hint:** As a good starting point, it is recommended to check papers citing the optimal checkpointing article[^Griewank1992] in Google Scholar.

[^Griewank1992]: Griewank, Andreas. "Achieving logarithmic growth of temporal and spatial complexity in reverse automatic differentiation." Optimization Methods and software 1.1 (1992): 35-54.
