using Test
include("question4.jl")

# 定义矩阵和向量
U = [1 2 3; 0 4 5; 0 0 6]
b = [7, 8, 9]

# 计算解
computed_x = back_substitution(U, b)

# 预期解
expected_x = [9/4, 1/8, 3/2]

# 测试结果是否匹配
@test computed_x ≈ expected_x atol=1e-10

println("测试通过！")