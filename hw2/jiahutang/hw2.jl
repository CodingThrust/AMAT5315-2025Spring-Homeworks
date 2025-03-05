
using Random
using BenchmarkTools
using Profile
using LinearAlgebra
using TropicalNumbers


# 测试表达式
println(Tropical(1.0) + Tropical(3.0))
println(Tropical(1.0) + Tropical(3.0))  # 输出: Tropical{Float64}(1.0)
println(Tropical(1.0) * Tropical(3.0))  # 输出: Tropical{Float64}(4.0)
println(one(Tropical{Float64}))        # 输出: Tropical{Float64}(0.0)
println(zero(Tropical{Float64}))       # 输出: Tropical{Float64}(Inf)

# 类型和超类型
println(typeof(Tropical(1.0)))         # 输出: Tropical{Float64}
println(supertype(Tropical{Float64}))  # 输出: Number

# 检查是否为具体类型
println(isconcretetype(Tropical))      # 输出: true
println(isconcretetype(Tropical{Real})) # 输出: false

# 性能基准测试
using BenchmarkTools
A = rand(Tropical{Float64}, 100, 100)
B = rand(Tropical{Float64}, 100, 100)
println(@btime $A * $B)                # 测量时间

# 性能分析
using Profile
@profile C = A * B
Profile.print()