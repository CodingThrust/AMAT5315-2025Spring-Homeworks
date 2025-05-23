1.
rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]

sp = sparse(rowindices, colindices, data, 5, 5);

println("colptr: ", sp.colptr)
println("rowval: ", sp.rowval)
println("nzval: ", sp.nzval)
println("m: ", sp.m)
println("n: ", sp.n)

2.
using Graphs, Random, KrylovKit, SparseArrays
Random.seed!(42)
g = random_regular_graph(100000, 3)

# 获取图的拉普拉斯矩阵并转换为稀疏矩阵
L = laplacian_matrix(g)
L_sparse = sparse(L)

eigen_vals, _ = eigsolve(L_sparse, randn(nv(g)), 5, :SR)

threshold = 1e-6
num_connected_components = count(eigen_val -> abs(eigen_val) < threshold, eigen_vals)

println("Number of connected components: ", num_connected_components)

3.
using LinearAlgebra

function restarting_lanczos(A, q1, s; max_restarts=5, tol=1e-10)
    n = size(A, 1)
    θ1_prev = 0.0
    q1 = normalize(q1)  

    for _ in 1:max_restarts
        Q = zeros(eltype(A), n, s)
        α = zeros(eltype(A), s)
        β = zeros(eltype(A), s-1)
        Q[:, 1] = q1

        # Lanczos迭代生成三对角矩阵
        for j in 1:s-1
            v = A * Q[:, j]
            α[j] = real(dot(Q[:, j], v))
            v = v - α[j] * Q[:, j]
            if j > 1  # 避免j=1时访问β[0]
                v = v - β[j-1] * Q[:, j-1]
            end
            β[j] = norm(v)
            if β[j] < tol  
                s = j  
                Q = Q[:, 1:s]
                α = α[1:s]
                β = β[1:s-1]
                break
            end
            Q[:, j+1] = v / β[j]
        end

        # 构造并分解三对角矩阵
        Ts = diagm(0 => α[1:s], 1 => β[1:s-1], -1 => β[1:s-1])
        F = eigen(Ts)
        θ = real(F.values)
        U = F.vectors
        
        # 获取最大特征值及其特征向量
        idx_max = argmax(θ)
        θ1 = θ[idx_max]
        q1_new = Q * U[:, idx_max]  # 更新q1为新的Ritz向量

        # 检查收敛性
        if abs(θ1 - θ1_prev) < tol
            return θ1, q1_new
        end
        θ1_prev = θ1
        q1 = normalize(q1_new)  
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