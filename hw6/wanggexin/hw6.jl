############################################################
# 1. 稀疏矩阵构造
############################################################
using SparseArrays

rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data       = [0.799, 0.942, 0.848, 0.164, 0.637]

sp = sparse(rowindices, colindices, data; m = 5, n = 5)   # 用关键词，更安全

############################################################
# 2. 计算连通分量 —— 拉普拉斯零特征检测
############################################################
using Graphs, Random, KrylovKit, SparseArrays, LinearAlgebra

Random.seed!(42)
g = random_regular_graph(100_000, 3)

A = adjacency_matrix(g)
d = vec(sum(A, dims = 2))
L = spdiagm(0 => d) - A                # 稀疏对角矩阵，避免密集 Diagonal

eigvals = eigsolve(L, 10, :SR; tol = 1e-7)[1]  # 只要特征值
num_connected_components = count(abs.(eigvals) .< 1e-8)     # 更严格阈值

############################################################
# 3. Restarting Lanczos（细节修正 + 轻量提速）
############################################################
using LinearAlgebra

function restarting_lanczos(A, q1, s; max_restarts = 5, tol = 1e-10)
    n        = size(A, 1)
    θ_prev   = -Inf
    q        = normalize(q1)
    Q        = similar(A, n, s)        # 复用内存
    α        = zeros(eltype(A), s)
    β        = zeros(eltype(A), s-1)

    for _ in 1:max_restarts
        Q[:, 1] = q
        k = 0                           # 实际步数

        for j in 1:s
            k = j
            v      = A * Q[:, j]
            α[j]   = dot(Q[:, j], v)
            v     .-= α[j] * Q[:, j]
            if j > 1
                v .-= β[j-1] * Q[:, j-1]
            end
            β[j]   = norm(v)
            β[j] < tol && break
            j < s && (Q[:, j+1] .= v ./ β[j])
        end

        T   = SymTridiagonal(view(α, 1:k), view(β, 1:k-1))   # 专用类型
        θs, U = eigen(T; sortby = :Magnitude)
        θ      = θs[end]               # 最大
        q      = @view(Q[:, 1:k]) * @view(U[:, end])

        abs(θ - θ_prev) < tol && return θ, q
        θ_prev = θ
    end
    return θ_prev, q
end

############################################################
# 4. 简易测试保持不变
############################################################
using Test, Random
Random.seed!(42)

@testset "Restarting Lanczos" begin
    n  = 100
    A  = randn(n, n); A = Symmetric(A + A')
    q0 = randn(n)
    s  = 20

    θ̂, v̂ = restarting_lanczos(A, q0, s)
    θ_true = maximum(eigen(A).values)

    @test isapprox(θ̂, θ_true; atol = 1e-6)
end
