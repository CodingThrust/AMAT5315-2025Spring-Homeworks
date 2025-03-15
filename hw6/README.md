# Homework 6

1. Please find out the correct values of `rowindices`, `colindices`, and `data` to reproduce the following sparse matrix in CSC format.
   ```julia
   julia> sp = sparse(rowindices, colindices, data, 5, 5);

   julia> sp.colptr
   6-element Vector{Int64}:
   1
   2
   3
   5
   6
   6

   julia> sp.rowval
   5-element Vector{Int64}:
   3
   1
   1
   4
   5

   julia> sp.nzval
   5-element Vector{Float64}:
   0.799
   0.942
   0.848
   0.164
   0.637

   julia> sp.m
   5

   julia> sp.n
   5
   ```

2. The following code generates a random 3-regular graph with $100000$ nodes. Please find out the number of connected components of the graph by diagonalizing the Laplacian matrix of the graph with `KrylovKit.jl`.
   ```julia
   using Graphs, Random, KrylovKit
   Random.seed!(42)
   g = random_regular_graph(100000, 3)
   # your code here
   ```

3. (Optional) The restarting Lanczos algorithm is a variant of the Lanczos algorithm that is used to compute a few eigenvalues and eigenvectors of a large matrix. Suppose we wish to calculate the largest eigenvalue of a symmetric matrix $A \in \mathbb{C}^{n\times n}$ with the Lanczos method. Let $q_1 \in \mathbb{C}^{n}$ being a normalized vector, the restarting Lanczos algorithm is as follows:

   1. Generate $q_2,\ldots,q_s \in \mathbb{C}^{n}$ via the Lanczos algorithm.
   2. Form $T_s = ( q_1 \mid \ldots \mid q_s)^T A ( q_1 \mid \ldots \mid q_s)$, an s-by-s matrix.
   3. Compute an orthogonal matrix $U = ( u_1 \mid \ldots\mid u_s)$ such that $U^T T_s U = {\rm diag}(\theta_1, \ldots, \theta_s)$ with $\theta_1\geq \ldots \geq\theta_s$.
   4. Set $q_1^{({\rm new})} = ( q_1 \mid \ldots \mid q_s)u_1$.

   Please implement a Lanczos tridiagonalization process with restarting as a Julia function. You submission should include that function as well as a test. 

4. (Challenge) Resolve the following issue in KrylovKit.jl: https://github.com/Jutho/KrylovKit.jl/issues/87 . If you can resolve the issue, please submit a pull request to the repository. If your PR is merged, your final grade will be $A+$.