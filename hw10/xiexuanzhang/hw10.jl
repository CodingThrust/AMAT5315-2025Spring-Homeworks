using FiniteDifferences
using ForwardDiff
using Enzyme

function poor_besselj(v, z::T; atol=eps(T)) where T
    k = 0
    s = (z / 2)^v / factorial(v)
    out = s
    while abs(s) > atol
        k += 1
        s *= (-1) / k / (k + v) * (z / 2)^2
        out += s
    end
    out
end

z = 2.0
v = 2

function finite_differences_gradient()
    return central_fdm(5, 1)(x -> poor_besselj(v, x), z)
end

function forward_diff_gradient()
    return ForwardDiff.derivative(x -> poor_besselj(v, x), z)
end

function enzyme_gradient()
    return autodiff(Enzyme.Reverse, x -> poor_besselj(v, x), 
                      Enzyme.Active, Enzyme.Active(z))[1]
end

println("使用FiniteDifferences.jl计算的梯度: ", finite_differences_gradient())
println("使用ForwardDiff.jl计算的梯度: ", forward_diff_gradient())
println("使用Enzyme.jl计算的梯度: ", enzyme_gradient())


2.
using Enzyme
using Optim
using LinearAlgebra
using Test

vertices = collect(1:10)
edges = [(1, 2), (1, 3),
         (2, 3), (2, 4), (2, 5), (2, 6),
         (3, 5), (3, 6), (3, 7),
         (4, 5), (4, 8),
         (5, 6), (5, 8), (5, 9),
         (6, 7), (6, 8), (6, 9),
         (7, 9), (8, 9), (8, 10), (9, 10)]

# 生成非边的顶点对
non_edges = [(u, v) for u in vertices for v in vertices if u < v && !((u, v) in edges || (v, u) in edges)]

n = length(vertices)
# 随机初始化顶点坐标
pos = rand(2n) .* 0.5 .- 0.25  

# 定义计算两点距离的函数
function distance(u, v, pos)
    dx = pos[2u - 1] - pos[2v - 1]
    dy = pos[2u] - pos[2v]
    return sqrt(dx^2 + dy^2)
end

# 定义损失函数
function loss(pos)
    loss_val = 0.0
    # 对边的约束
    for (u, v) in edges
        dist = distance(u, v, pos)
        loss_val += 100 * max(0, dist - 1)^2  
    end
    # 对非边的约束
    for (u, v) in non_edges
        dist = distance(u, v, pos)
        loss_val += 100 * max(0, 1 - dist)^2 
    end
    # 对顶点在单位圆盘内的约束
    for i in 1:n
        x, y = pos[2i - 1], pos[2i]
        r = sqrt(x^2 + y^2)
        loss_val += 10 * max(0, r - 1)^2  
    end
    return loss_val
end

# 定义梯度计算函数
function grad_loss!(grad, pos)
    grad .= 0.0
    autodiff(Enzyme.Reverse, loss, Enzyme.Active, Enzyme.Duplicated(pos, grad))
    return nothing
end

# 优化损失函数
result = optimize(loss, grad_loss!, pos, LBFGS(),
                  Optim.Options(show_trace=true, iterations=2000, g_tol=1e-10))

optimized_pos = Optim.minimizer(result)
# 得到嵌入后的顶点坐标
embedding = [(optimized_pos[2i - 1], optimized_pos[2i]) for i in 1:n]

# 测试嵌入结果是否满足条件
@testset "Unit-disk embedding validation" begin
    edge_tolerance = 0.05
    non_edge_tolerance = 0.05
    for (u, v) in edges
        dist = distance(u, v, embedding)
        @test dist ≤ 1 + edge_tolerance
    end
    for (u, v) in non_edges
        dist = distance(u, v, embedding)
        @test dist ≥ 1 - non_edge_tolerance
    end
end