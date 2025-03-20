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


#################################
# 3.
using LinearAlgebra, Test, Random

function restarting_lanczos(A, q1, s, max_restarts=20, tol=1e-10)
    """
    重启 Lanczos 算法实现

    参数:
    - A: 对称矩阵 (n x n)
    - q1: 初始向量 (n x 1)
    - s: Lanczos 向量的数量
    - max_restarts: 最大重启次数
    - tol: 收敛容差

    返回:
    - θ: 近似最大特征值
    - q: 近似最大特征向量
    """
    n = size(A, 1)
    q1 = q1 / norm(q1)  # 归一化初始向量

    for restart in 1:max_restarts
        # 初始化 Lanczos 向量和三对角矩阵
        Q = zeros(n, s)
        T = zeros(s, s)
        Q[:, 1] = q1

        # Lanczos 过程
        β = 0.0  # 初始化 β
        for j in 1:s-1
            v = A * Q[:, j]
            α = dot(Q[:, j], v)
            T[j, j] = α
            v -= α * Q[:, j]

            if j > 1
                v -= β * Q[:, j-1]
            end

            β = norm(v)
            if β < tol
                break  # 提前终止
            end

            T[j, j+1] = β
            T[j+1, j] = β
            Q[:, j+1] = v / β
        end

        # 计算 T 的特征值分解
        θ, U = eigen(T)
        θ_max = θ[end]  # 最大特征值
        u1 = U[:, end]  # 最大特征值对应的特征向量

        # 更新初始向量
        q1_new = Q * u1

        # 检查收敛
        if norm(A * q1_new - θ_max * q1_new) < tol
            return θ_max, q1_new
        end

        q1 = q1_new
    end

    # 如果未收敛，返回最后一次结果
    return θ_max, q1
end

# 测试
n = 100
A = randn(n, n)  # 使矩阵对角占优，确保特征值分布良好
A = A + A'  # 使矩阵对称
q1 = rand(n)

θ_max, q_max = restarting_lanczos(A, q1, 20, 50, 1e-12)
residual_norm = norm(A * q_max - θ_max * q_max)/norm(q_max)
println("Approximated largest eigenvalue: ", θ_max)
println("Residual norm: ", residual_norm)
@test residual_norm < 1e-10