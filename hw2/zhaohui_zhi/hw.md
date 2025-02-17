# Homework done by Zhaohui Zhi

## Task 1 Answer
1.  ```julia
    julia> Tropical(1.0) + Tropical(3.0)
            3.0ₜ
    julia> Tropical(1.0) * Tropical(3.0)
            4.0ₜ
    julia> one(Tropical{Float64})
            0.0ₜ
    julia> zero(Tropical{Float64})
            -Infₜ
    ```

2. ```julia
    julia> typeof(Tropical(1.0))
            Tropical{Float64}
    julia> supertype(Tropical{Float64})
            AbstractSemiring
   ```

3. Is `Tropical` a concrete type or an abstract type? -> concrete type.
4. Is `Tropical{Real}` a concrete type or an abstract type? -> concrete type.
5. ```julia
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


   Count  Overhead File                                        Line Function
    =====  ======== ====                                        ==== ========
    22         0 @Base/boot.jl                                370 eval
    22         0 @Base/essentials.jl                          819 #invokelatest#2
    22         0 @Base/essentials.jl                          819 invokelatest(::Any, ::Any, ::Vararg{Any}; kwargs::Base.Pairs...
    22         0 @Base/essentials.jl                          816 invokelatest(::Any)
    12        11 @Base/floatfuncs.jl                           15 signbit
    22         0 @Base/loading.jl                            1903 include_string(mapexpr::typeof(REPL.softscope), mod::Module,...
    22         0 @Base/logging.jl                             626 with_logger
    22         0 @Base/logging.jl                             514 with_logstate(f::Function, logstate::Any)
    14         0 @Base/math.jl                                863 max
    22         0 @Base/task.jl                                514 (::VSCodeServer.var"#64#65")()
    22         0 @VSCodeServer/src/eval.jl                    263 (::VSCodeServer.var"#66#71"{VSCodeServer.ReplRunCodeRequestP...
    22         0 @VSCodeServer/src/eval.jl                    150 (::VSCodeServer.var"#67#72"{Bool, Bool, Bool, Module, String...
    22         0 @VSCodeServer/src/eval.jl                    179 (::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String...
    22         0 @VSCodeServer/src/eval.jl                    181 (::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String...
    22         0 @VSCodeServer/src/eval.jl                    271 inlineeval(m::Module, code::String, code_line::Int64, code_c...
    22         0 @VSCodeServer/src/eval.jl                    268 kwcall(::NamedTuple{(:softscope,), Tuple{Bool}}, ::typeof(VS...
    22         0 @VSCodeServer/src/eval.jl                     34 macro expansion
    22         0 @VSCodeServer/src/repl.jl                     38 hideprompt(f::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Mod...
    22         0 @VSCodeServer/src/repl.jl                    276 withpath(f::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Modul...
    15         0 ...-Homeworks/hw2/Tropical_Sets_Algebra.jl    47 +
    20         0 ...-Homeworks/hw2/Tropical_Sets_Algebra.jl    95 macro expansion
    22         0 ...stdlib/v1.9/LinearAlgebra/src/matmul.jl   141 *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
    17         0 ...stdlib/v1.9/LinearAlgebra/src/matmul.jl   913 _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, ...
    21         0 ...stdlib/v1.9/LinearAlgebra/src/matmul.jl   844 generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, t...
    21         0 ...stdlib/v1.9/LinearAlgebra/src/matmul.jl   276 mul!
    21         0 ...stdlib/v1.9/LinearAlgebra/src/matmul.jl   303 mul!
    20         0 ...ulia/stdlib/v1.9/Profile/src/Profile.jl    27 top-level scope
    Total snapshots: 24. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
    ```

## Task 2 Answer

Source code:
```julia

```
Also refer to the attached file.
