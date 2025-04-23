using LinearAlgebra

# 参数设置
N = 21
C = 3.0
m_e = 1.0
m_o = 2.0

# 构造质量矩阵 M（对角矩阵，奇数位质量为2，偶数位为1）
masses = [isodd(i) ? m_o : m_e for i in 1:N]
M = diagm(masses)

# 构造刚度矩阵 K（三对角矩阵）
K = Tridiagonal(
    -C * ones(N-1),   # 次对角线（下）
     2C * ones(N),    # 主对角线
    -C * ones(N-1)    # 次对角线（上）
)

# 解广义特征值问题 K v = ω² M v
eigenvals = eigen(K, M).values

# 提取实部并计算特征频率（虚部应为零，忽略数值误差）
frequencies = sqrt.(real(eigenvals)) ./ (2π)

# 按升序排序
sorted_freq = sort(frequencies)

# 输出结果
println("前10个特征频率 (Hz)：")
for i in 1:10
    println("ωₖ = ", round(sorted_freq[i], digits=4))
end