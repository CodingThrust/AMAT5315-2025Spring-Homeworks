using Random
abstract type AbstractSemiring <: Number end

# define the -inf
neginf(::Type{T}) where T = typemin(T)
neginf(::Type{T}) where T<:AbstractFloat = typemin(T)
neginf(::Type{T}) where T<:Rational = typemin(T)
neginf(::Type{T}) where T<:Integer = T(-999999)
neginf(::Type{Int16}) = Int16(-16384)
neginf(::Type{Int8}) = Int8(-64)
posinf(::Type{T}) where T = - neginf(T)

struct Tropical{T} <: AbstractSemiring
    n::T
    Tropical{T}(x) where T = new{T}(T(x))
    function Tropical(x::T) where T
        new{T}(x)
    end
    function Tropical{T}(x::Tropical{T}) where T
        x
    end
    function Tropical{T1}(x::Tropical{T2}) where {T1,T2}
        # new is the default constructor
        new{T1}(T2(x.n))
    end
end

# customize the print
Base.show(io::IO, t::Tropical) = Base.print(io, "$(t.n)ₜ")

# power is mapped to multiplication
Base.:^(a::Tropical, b::Real) = Tropical(a.n * b)
Base.:^(a::Tropical, b::Integer) = Tropical(a.n * b)

# multiplication is mapped to addition
Base.:*(a::Tropical, b::Tropical) = Tropical(a.n + b.n)
function Base.:*(a::Tropical{<:Rational}, b::Tropical{<:Rational})
    if a.n.den == 0
        a
    elseif b.n.den == 0
        b
    else
        Tropical(a.n + b.n)
    end
end

# addition is mapped to max
Base.:+(a::Tropical, b::Tropical) = Tropical(max(a.n, b.n))

# minimum value of the semiring
Base.typemin(::Type{Tropical{T}}) where T = Tropical(neginf(T))

# additive identity (zero element) - defined on types
Base.zero(::Type{Tropical{T}}) where T = typemin(Tropical{T})
# additive identity (zero element)
Base.zero(::Tropical{T}) where T = zero(Tropical{T})

# multiplicative identity (one element)
Base.one(::Type{Tropical{T}}) where T = Tropical(zero(T))
Base.one(::Tropical{T}) where T = one(Tropical{T})

# inverse is mapped to negative
Base.inv(x::Tropical) = Tropical(-x.n)

# division is mapped to subtraction
Base.:/(x::Tropical, y::Tropical) = Tropical(x.n - y.n)
# `div` is similar to `/`, the only difference is that `div(::Int, ::Int) -> Int`, but `/(::Int, ::Int) -> Float64`
Base.div(x::Tropical, y::Tropical) = Tropical(x.n - y.n)

# two numbers are approximately equal. For floating point numbers, this is often preferred to `==` due to the rounding error.
Base.isapprox(x::Tropical, y::Tropical; kwargs...) = isapprox(x.n, y.n; kwargs...)

# promotion rules
Base.promote_type(::Type{Tropical{T1}}, b::Type{Tropical{T2}}) where {T1, T2} = Tropical{promote_type(T1,T2)}

function Random.rand(rng::AbstractRNG, ::Random.SamplerType{Tropical{T}}) where T
    Tropical{T}(rand(rng, T))
end

############################# Task 1
# 1.

Tropical(1.0) + Tropical(3.0)
# 3.0ₜ

Tropical(1.0) * Tropical(3.0)
# 4.0ₜ

one(Tropical{Float64})
# 0.0ₜ

zero(Tropical{Float64})
# -Infₜ



###############################
# 2.
typeof(Tropical(1.0))
# Tropical{Float64}

supertype(Tropical{Float64})
# AbstractSemiring

#################################
# 3.

# Neither of them.


##################################
# 4.
# Tropical{Real} is a concrete type


########################################
# 5.

using BenchmarkTools, Profile

A = rand(Tropical{Float64}, 100, 100)
B = rand(Tropical{Float64}, 100, 100)
C = A * B 

@btime C = A * B
# 639.167 μs (3 allocations: 78.20 KiB)

Profile.clear()
@profile C = A * B
Profile.print()
````
Overhead ╎ [+additional indent] Count File:Line; Function
=========================================================
 ╎1 @VSCodeServer/src/eval.jl:34; (::VSCodeServer.var"#64#65")()
 ╎ 1 @Base/essentials.jl:1052; invokelatest(::Any)
 ╎  1 @Base/essentials.jl:1055; #invokelatest#2
 ╎   1 @VSCodeServer/src/eval.jl:263; (::VSCodeServer.var"#66#71"{VSCodeServer.ReplRunCodeRequestParams})()
 ╎    1 @Base/logging/logging.jl:632; with_logger
 ╎     1 @Base/logging/logging.jl:522; with_logstate(f::VSCodeServer.var"#67#72"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRu…
 ╎    ╎ 1 @VSCodeServer/src/eval.jl:150; #67
 ╎    ╎  1 @VSCodeServer/src/repl.jl:38; hideprompt(f::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRun…
 ╎    ╎   1 @VSCodeServer/src/eval.jl:179; (::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeReque…
 ╎    ╎    1 @VSCodeServer/src/repl.jl:276; withpath(f::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRu…
 ╎    ╎     1 @VSCodeServer/src/eval.jl:181; (::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeReq…
 ╎    ╎    ╎ 1 @VSCodeServer/src/eval.jl:268; kwcall(::@NamedTuple{softscope::Bool}, ::typeof(VSCodeServer.inlineeval), m::Module, code::String, code_line::…
 ╎    ╎    ╎  1 @VSCodeServer/src/eval.jl:271; inlineeval(m::Module, code::String, code_line::Int64, code_column::Int64, file::String; softscope::Bool)
 ╎    ╎    ╎   1 @Base/essentials.jl:1052; invokelatest(::Any, ::Any, ::Vararg{Any})
 ╎    ╎    ╎    1 @Base/essentials.jl:1055; invokelatest(::Any, ::Any, ::Vararg{Any}; kwargs::Base.Pairs{Symbol, Union{}, Tuple{}, @NamedTuple{}})
 ╎    ╎    ╎     1 @Base/loading.jl:2734; include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)
 ╎    ╎    ╎    ╎ 1 @Base/boot.jl:430; eval
 ╎    ╎    ╎    ╎  1 @LinearAlgebra/src/matmul.jl:114; *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
 ╎    ╎    ╎    ╎   1 @LinearAlgebra/src/matmul.jl:253; mul!
 ╎    ╎    ╎    ╎    1 @LinearAlgebra/src/matmul.jl:285; mul!
 ╎    ╎    ╎    ╎     1 @LinearAlgebra/src/matmul.jl:287; _mul!
 ╎    ╎    ╎    ╎    ╎ 1 @LinearAlgebra/src/matmul.jl:868; generic_matmatmul!
 ╎    ╎    ╎    ╎    ╎  1 @LinearAlgebra/src/matmul.jl:895; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{Tropic…
 ╎    ╎    ╎    ╎    ╎   1 @Base/simdloop.jl:77; macro expansion
 ╎    ╎    ╎    ╎    ╎    1 @LinearAlgebra/src/matmul.jl:896; macro expansion
 ╎    ╎    ╎    ╎    ╎     1 @Base/array.jl:930; getindex
 ╎    ╎    ╎    ╎    ╎    ╎ 1 @Base/abstractarray.jl:1347; _to_linear_index
 ╎    ╎    ╎    ╎    ╎    ╎  1 @Base/abstractarray.jl:3048; _sub2ind
 ╎    ╎    ╎    ╎    ╎    ╎   1 @Base/abstractarray.jl:98; axes
 ╎    ╎    ╎    ╎    ╎    ╎    1 @Base/array.jl:194; size
Total snapshots: 1. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```

######################################## Task 6
using Test

function ⊕(a::Set, b::Set)
    return Set(union(a, b))
end

function ⊙(a::Set, b::Set)
    c = Set()
    for i in a
        for j in b
            push!(c, i * j)
        end
    end
    return c
end

a = Set([2])
b = Set([5, 4])
c = Set()

@testset "Set operations" begin
    @test a ⊕ b == b ⊕ a == Set([2,4,5])
    @test a ⊕ c == a
    @test a ⊙ b == b ⊙ a == Set([10,8])
    @test a ⊙ c == c
    @test a ⊙ Set([1]) == a
end
#= 
Test Summary:  | Pass  Total  Time
Set operations |    5      5  0.4s
=#
