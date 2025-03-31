using SparseArrays

rowindices=[3,1,1,4,5]
colindices=[1,2,3,3,4]
data=[0.799,0.942,0.848,0.164,0.637]

A=sparse(rowindices, colindices, data,5,5)

@show A.rowval
@show A.colptr
@show A.nzval

#= =#

using Graphs, Random, KrylovKit
Random.seed!(42)
g = random_regular_graph(100000, 3)
L=laplacian_matrix(g)
vals, vecs = eigsolve(L, 10, :SR)
@show vals
#= =#