# Homework 6
## 1. Sparse matrix
### question
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
### answer
```julia
rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]
```
```julia
julia> using SparseArrays
julia> sp = sparse(rowindices, colindices, data, 5, 5)
5×5 SparseMatrixCSC{Float64, Int64} with 5 stored entries:
  ⋅     0.942  0.848   ⋅      ⋅ 
  ⋅      ⋅      ⋅      ⋅      ⋅ 
 0.799   ⋅      ⋅      ⋅      ⋅ 
  ⋅      ⋅     0.164   ⋅      ⋅ 
  ⋅      ⋅      ⋅     0.637   ⋅ 
```
## 2. Graph spectral analysis
```julia
using Graphs, Random, SparseArrays, LinearAlgebra, KrylovKit

Random.seed!(42)
g = random_regular_graph(100000, 3)

n = nv(g)
A = adjacency_matrix(g)
D = spdiagm(0 => fill(3.0, n))
L = D - A
λs, _ = eigsolve(L, 1, :SR)
num_components = count(abs.(λs) .< 1e-6)
println("Number of connected components: ", num_components)
```
```julia
julia> println("Number of connected components: ", num_components)
Number of connected components: 1
```
```markdown
The number of connected componenets is equal to the multiplicity of the eigenvalue 0 in the Laplacian matrix.
```