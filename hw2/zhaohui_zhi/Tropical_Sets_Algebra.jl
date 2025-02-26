abstract type AbstractSemiring <: Number end

struct Tropical_Set{T} <: AbstractSemiring where T <: Set
    n::T
    Tropical_Set{T}(x) where T = new{T}(T(x))
    function Tropical_Set(x::T) where T <: Set
        # if !(T <: Set)
        #     throw(ArgumentError("T must be a subtype of Set"))
        # end
        new{T}(x)
    end
    function Tropical_Set{T}(x::Tropical_Set{T}) where T <: Set
        x
    end
    function Tropical_Set{T1}(x::Tropical_Set{T2}) where {T1 <: Set,T2 <: Set}
        # new is the default constructor
        new{T1}(T1(x.n))
    end
end

Base.in(x, ts::Tropical_Set) = x in ts.n
Base.union(ts1::Tropical_Set, ts2::Tropical_Set) = Tropical_Set(union(ts1.n, ts2.n))

# customize the print
Base.show(io::IO, t::Tropical_Set) = Base.print(io, "$(t.n)ₛ")

# multiplication is mapped to element-wise logical or

function Base.:*(a::Tropical_Set, b::Tropical_Set)
    Tropical_Set(Set(x * y for x in a.n for y in b.n))
end

# addition is mapped to union
Base.:+(a::Tropical_Set, b::Tropical_Set) = union(a, b)

# additive identity (zero element)
Base.zero(::Type{Tropical_Set{T}}) where T = Tropical_Set(Set{T}())
Base.zero(::Tropical_Set{T}) where T = zero(Tropical_Set{T})

# multiplicative identity (one element)
Base.one(::Type{Tropical_Set{T}}) where T = Tropical_Set(Set{T}([1]))
Base.one(::Tropical_Set{T}) where T = one(Tropical_Set{T})

# two numbers are approximately equal. For floating point numbers, this is often preferred to `==` due to the rounding error.
Base.:(==)(x::Tropical_Set, y::Tropical_Set; kwargs...) = x.n==y.n

# promotion rules
Base.promote_type(::Type{Tropical_Set{T1}}, b::Type{Tropical_Set{T2}}) where {T1, T2} = Tropical_Set{promote_type(T1,T2)}




