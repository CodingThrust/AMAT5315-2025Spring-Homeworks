# Homework 2

## Task 1: Tropical Max-Plus Algebra

# What are the outputs of the following expressions?


```julia
using TropicalNumbers
println(Tropical(1.0) + Tropical(3.0))
println(one(Tropical{Float64}))
println(zero(Tropical{Float64}))
```

    3.0ₜ
    0.0ₜ
    -Infₜ


What is the type and supertype of Tropical(1.0)?
    Tropical{Float64} and  AbstractSemiring

```julia
println(typeof(Tropical(1.0)))
println(supertype(Tropical{Float64}))
```

    Tropical{Float64}
    AbstractSemiring


Is Tropical a concrete type or an abstract type?
    Tropical without a type parameter is a UnionAll type.

```julia
isconcretetype(Tropical)
```
    false

```julia
isabstracttype(Tropical)
```
    false

```julia
typeof(Tropical)
isconcretetype(Tropical{Float64})
```
    UnionAll
    true

Is Tropical{Real} a concrete type or an abstract type?
    concrete type 

```julia
isconcretetype(Tropical{Real})
```
    true

```julia
isabstracttype(Tropical{Real})
```

    false


Benchmark and profile the performance of Tropical matrix multiplication:


```julia
using Random
using BenchmarkTools
using Profile

function Base.rand(::Type{Tropical{T}}, rng::AbstractRNG) where T
    return Tropical(rand(rng, T))  
end

function Base.rand(::Type{Tropical{T}}, dims::Tuple{Vararg{Int}}) where T
    rng = Random.TaskLocalRNG()  # 使用默认的随机数生成器
    # 生成一个一维数组，然后将其重塑为指定的维度
    return reshape([rand(Tropical{T}, rng) for _ in 1:prod(dims)], dims)
end


A = rand(Tropical{Float64}, 100, 100)
B = rand(Tropical{Float64}, 100, 100)


@btime C = A * B # 2.066 ms
@profile for i in 1:10; A * B; end
Profile.print(format=:flat,mincount=10)

```

      1.499 ms (3 allocations: 78.20 KiB)
     Count  Overhead File                    Line Function
     =====  ======== ====                    ==== ========
        53         0 @Base/Base.jl            557 include(mod::Module, _path::Strin…
        14        14 @Base/array.jl           994 setindex!
        53         0 @Base/boot.jl            430 eval
        53         0 @Base/client.jl          531 _start()
        53         0 @Base/client.jl          323 exec_options(opts::Base.JLOptions)
        53         0 @Base/essentials.jl     1055 #invokelatest#2
        17        17 @Base/essentials.jl      796 ifelse
        53         0 @Base/essentials.jl     1052 invokelatest
        53         0 @Base/loading.jl        2794 _include(mapexpr::Function, mod::…
        53         0 @Base/loading.jl        2734 include_string(mapexpr::typeof(id…
        12         0 @Base/math.jl            839 max
        22         0 @Base/promotion.jl       633 muladd
        45         0 @Base/simdloop.jl         77 macro expansion
        53         0 …Algebra/src/matmul.jl   114 *(A::Matrix{Tropical{Float64}}, B…
        46         0 …Algebra/src/matmul.jl   895 _generic_matmatmul!(C::Matrix{Tro…
        47         0 …Algebra/src/matmul.jl   287 _mul!
        47         0 …Algebra/src/matmul.jl   868 generic_matmatmul!
        45         0 …Algebra/src/matmul.jl   896 macro expansion
        47         0 …Algebra/src/matmul.jl   253 mul!
        47         0 …Algebra/src/matmul.jl   285 mul!
        53         0 …rofile/src/Profile.jl    59 macro expansion
        20         0 …c/tropical_maxplus.jl    67 +
        53         0 …/notebook/notebook.jl    35 top-level scope
        53         0 @JSONRPC/src/typed.jl     67 dispatch_msg(x::VSCodeServer.JSON…
        53         0 …odeServer/src/repl.jl   276 withpath(f::VSCodeServer.var"#217…
        53         0 …src/serve_notebook.jl    24 (::VSCodeServer.var"#217#218"{VSC…
        53         0 …src/serve_notebook.jl   147 serve_notebook(pipename::String, …
        53         0 …src/serve_notebook.jl    13 notebook_runcell_request(conn::VS…
        53         0 …src/serve_notebook.jl    81 kwcall(::@NamedTuple{error_handle…
        53         0 …Njb2RlLXJlbW90ZQ==.jl    21 macro expansion
        53         0 …Njb2RlLXJlbW90ZQ==.jl    21 top-level scope
    Total snapshots: 53. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.

The benchmark shows that multiplying two 100x100 Tropical{Float64} matrices takes 2.066 ms with 78.20 KiB memory allocated. Profiling over 10 iterations confirms efficient execution, dominated by core matrix multiplication functions (*, _mul!, etc.), with minimal overhead and no significant bottlenecks.



# Task 2: Implement the the following semiring algebra over sets:


```julia
struct SetSemiring
    elements::Set{Int}
    
    # 外部构造函数：允许通过多个整数构造（如 SetSemiring(1, 2, 3)）
    SetSemiring(args::Integer...) = new(Set(args))
    
    # 内部构造函数：直接接受 Set{Int} 类型（用于运算结果）
    SetSemiring(s::Set{Int}) = new(s)
end

# 加法：集合的并集
Base.:(+)(a::SetSemiring, b::SetSemiring) = SetSemiring(union(a.elements, b.elements))

# 乘法：所有元素乘积的集合
Base.:(*)(a::SetSemiring, b::SetSemiring) = SetSemiring(Set(x * y for x in a.elements for y in b.elements))

# 零元：空集
Base.zero(::Type{SetSemiring}) = SetSemiring(Set{Int}())

# 单位元：包含1的集合
Base.one(::Type{SetSemiring}) = SetSemiring(1)

# 相等性判断
Base.:(==)(a::SetSemiring, b::SetSemiring) = a.elements == b.elements

# 自定义显示格式
Base.show(io::IO, s::SetSemiring) = print(io, "SetSemiring($(s.elements))")
```

test code like this


```julia
using Test

@testset "SetSemiring Tests" begin
    # 加法测试
    @test SetSemiring(2) + SetSemiring(5, 4) == SetSemiring(2, 4, 5)
    @test SetSemiring(5, 4) + SetSemiring(2) == SetSemiring(2, 4, 5)
    @test SetSemiring(2) + zero(SetSemiring) == SetSemiring(2)
    
    # 乘法测试
    @test SetSemiring(2) * SetSemiring(5, 4) == SetSemiring(10, 8)
    @test SetSemiring(5, 4) * SetSemiring(2) == SetSemiring(10, 8)
    @test SetSemiring(2) * zero(SetSemiring) == zero(SetSemiring)
    @test zero(SetSemiring) * SetSemiring(2) == zero(SetSemiring)
    @test SetSemiring(2) * one(SetSemiring) == SetSemiring(2)
    @test one(SetSemiring) * SetSemiring(2) == SetSemiring(2)
    
    # 零元和单位元测试
    @test zero(SetSemiring) == SetSemiring()
    @test one(SetSemiring) == SetSemiring(1)
end
```

    [0m[1mTest Summary:     | [22m[32m[1mPass  [22m[39m[36m[1mTotal  [22m[39m[0m[1mTime[22m
    SetSemiring Tests | [32m  11  [39m[36m   11  [39m[0m0.1s



    Test.DefaultTestSet("SetSemiring Tests", Any[], 11, false, false, true, 1.740988775826436e9, 1.740988775975418e9, false, "/hpc2hdd/home/chuo657/work-tjh/AMAT5315/AMAT5315-2025Spring-Homeworks/hw2/JiahuTANG/jl_notebook_cell_df34fa98e69747e1a8f8a730347b8e2f_X33sdnNjb2RlLXJlbW90ZQ==.jl")

