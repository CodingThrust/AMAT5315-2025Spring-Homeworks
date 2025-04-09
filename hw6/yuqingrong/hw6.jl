#### 1.
using SparseArrays

rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]

sp = sparse(rowindices, colindices, data, 5, 5)

sp.colptr == [1, 2, 3, 5, 6, 6]  # true
sp.rowval == [3, 1, 1, 4, 5]     # true
sp.nzval == [0.799, 0.942, 0.848, 0.164, 0.637]  # true
sp.m == 5  # true
sp.n == 5  # true   


#### 2.
using Graphs, Random, KrylovKit, SparseArrays, LinearAlgebra

Random.seed!(42)
g = random_regular_graph(100000, 3)

A = adjacency_matrix(g)  
D = Diagonal(vec(sum(A, dims=2)))  
L = D - A  

vals, _ = eigsolve(L, 10, :SR)  

num_connected_components = count(x -> abs(x) < 1e-4, vals)
# => 1



#### 3.

using LinearAlgebra

function restarting_lanczos(A, q1, s; max_restarts=5, tol=1e-10)
    n = size(A, 1)
    θ1_prev = 0.0
    q1 = normalize(q1)

    for _ in 1:max_restarts
        Q = zeros(n, s)
        α = zeros(s)
        β = zeros(s-1)
        Q[:, 1] = q1

        for j in 1:s-1
            v = A * Q[:, j]
            α[j] = real(dot(Q[:, j], v))
            v = v .- α[j] .* Q[:, j] .- (j > 1 ? β[j-1] .* Q[:, j-1] : 0.0)  # Fixed line
            β[j] = norm(v)
            if β[j] < tol
                break
            end
            Q[:, j+1] = v ./ β[j]
        end

        Ts = diagm(0 => α[1:s], 1 => β[1:s-1], -1 => β[1:s-1])
        F = eigen(Ts)
        θ = real(F.values)
        U = F.vectors
        θ1 = maximum(θ)
        q1_new = Q[:, 1:s] * U[:, argmax(θ)]

        if abs(θ1 - θ1_prev) < tol
            return θ1, q1_new
        end
        θ1_prev = θ1
        q1 = q1_new
    end
    return θ1_prev, q1
end

using Test
using Random
Random.seed!(42)

@testset "Restarting Lanczos" begin

    n = 100
    A = randn(n, n)
    A = A + A'  

    q1 = randn(n)
    q1 = normalize(q1)

    s = 20  

    θ1, v1 = restarting_lanczos(A, q1, s)
    θ_true = maximum(eigen(A).values)

    @test isapprox(θ1, θ_true, atol=1e-6)
end

