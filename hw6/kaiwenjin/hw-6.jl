# 1.

using SparseArrays

rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]

sp = sparse(rowindices, colindices, data, 5, 5)

println("colptr: ", sp.colptr)
println("rowval: ", sp.rowval)
println("nzval: ", sp.nzval)

#################################
# 2.

using SparseArrays, Graphs, Random, KrylovKit, LinearAlgebra

Random.seed!(42)

g = random_regular_graph(100000, 3)

L = laplacian_matrix(g)

L_sparse = sparse(L)


vals, _ = eigsolve(L_sparse,rand(100000), 5, :SR, KrylovKit.Lanczos())


zero_threshold = 1e-6 
num_zero_eigenvalues = count(x -> abs(x) < zero_threshold, vals)

#  the number of connected components = 1

