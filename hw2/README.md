# Homework 2

Tropical Max-Plus Algebra is a Semiring algebra. It maps
* `+` to `max` in regular algebra,
* `*` to `+` in regular algebra,
* `1` to `0` in regular algebra,
* `0` to `-Inf` in regular algebra (for integer content types, this is chosen as a small integer).

Consider the following implementation of the Tropical Max-Plus Algebra:

```julia
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
```

Task 1: Open a Julia REPL, run the code above, and answer the following questions:
1. What are the outputs of the following expressions?
    ```julia
    julia> Tropical(1.0) + Tropical(3.0)
    julia> Tropical(1.0) * Tropical(3.0)
    julia> one(Tropical{Float64})
    julia> zero(Tropical{Float64})
    ```

2. What is the type and supertype of `Tropical(1.0)`?
3. Is `Tropical` a concrete type or an abstract type?
4. Is `Tropical{Real}` a concrete type or an abstract type?
5. Benchmark the performance of Tropical matrix multiplication:
   ```julia
   A = rand(Tropical{Float64}, 100, 100)
   B = rand(Tropical{Float64}, 100, 100)
   C = A * B   # please measure the time taken
   ```

Task 2: Implement the Min-Plus Tropical Algebra, where `+` is replaced with `min` and `*` is replaced with `+`.