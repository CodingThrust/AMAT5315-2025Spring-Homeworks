1.
using SparseArrays
rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]
sp = sparse(rowindices, colindices, data, 5, 5)
println("colptr: ", sp.colptr)
println("rowval: ", sp.rowval)
println("nzval: ", sp.nzval)

2.
using Graphs, Random, KrylovKit
Random.seed!(42)
g = random_regular_graph(100000, 3)
L = laplacian_matrix(g)
eigvals, eigvecs = eigsolve(L, 10, :SR)
num_connected_components = count(x -> x == 0, eigvals)
println("Number of connected components: ", num_connected_components)