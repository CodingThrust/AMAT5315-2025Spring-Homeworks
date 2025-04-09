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


# Answer


```markdown
rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]
```
```julia
using SparseArrays
sparse([3, 1, 1, 4, 5],[1, 2, 3, 3, 4],[0.799, 0.942, 0.848, 0.164, 0.637],5,5)
```

#### Final Sparse Matrix
$\begin{bmatrix} \cdot & 0.942 & 0.848 & \cdot & \cdot \\ 0.848 & \cdot & \cdot & \cdot & \cdot \\ \cdot & \cdot & \cdot & \cdot & \cdot \\ \cdot & \cdot & \cdot & 0.164 & \cdot \\ \cdot & \cdot & \cdot & \cdot & 0.637 \end{bmatrix}$


2. The following code generates a random 3-regular graph with $100000$ nodes. Please find out the number of connected components of the graph by diagonalizing the Laplacian matrix of the graph with `KrylovKit.jl`.
   ```julia
    using Graphs, Random, KrylovKit
    Random.seed!(42)
    g = random_regular_graph(100000, 3)

    # Compute the Laplacian matrix
    n = nv(g)  # Number of vertices
    A = adjacency_matrix(g)  # Adjacency matrix
    D = Diagonal(fill(3, n))  # Degree matrix (diagonal with all entries 3)
    L = Matrix(D - A)  # Laplacian matrix
    L_sparse = sparse(L)
    eigenvalues, eigenvectors = eigsolve(L_sparse, randn(size(L_sparse, 1)), 1, :SR)

    num_connected_components = count(x -> abs(x) < 1e-6, eigenvalues)
    println("Number of connected components: ", num_connected_components)
   ```
  #### Output
   1
   

   The multiplicity of the eigenvalue 0 in the Laplacian matrix corresponds to the number of connected components.