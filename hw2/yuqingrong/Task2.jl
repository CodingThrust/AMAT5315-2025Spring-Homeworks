struct SetSemiring{T}
    set::Set{T}
    function SetSemiring(set::Set{T}) where T
        new{T}(set)
    end
end

SetSemiring(x::AbstractVector{T}) where T = SetSemiring(Set(x))

function Base.show(io::IO, s::SetSemiring)
    elements = sort(collect(s.set))  
    print(io, "{", join(elements, ", "), "}")
end

Base.:+(a::SetSemiring{T}, b::SetSemiring{T}) where T = SetSemiring(union(a.set, b.set))

Base.:*(a::SetSemiring{T}, b::SetSemiring{T}) where T = SetSemiring(Set([σ * τ for σ in a.set for τ in b.set]))

Base.zero(::Type{SetSemiring{T}}) where T = SetSemiring(Set{T}())
Base.zero(a::SetSemiring{T}) where T = zero(SetSemiring{T})

Base.one(::Type{SetSemiring{T}}) where T = SetSemiring(Set{T}([one(T)]))
Base.one(a::SetSemiring{T}) where T = one(SetSemiring{T})

Base.:(==)(a::SetSemiring{T}, b::SetSemiring{T}) where T = a.set == b.set


using Test
@testset "semiring set" begin
    @test SetSemiring([2]) + SetSemiring([5,4]) == SetSemiring([5,4]) + SetSemiring([2]) ==  SetSemiring([2,5,4])
    @test SetSemiring([2]) + zero(SetSemiring{Int}) == SetSemiring([2])
    @test SetSemiring([2]) * SetSemiring([5,4]) == SetSemiring([5,4]) * SetSemiring([2]) == SetSemiring([10,8])
    @test SetSemiring([2]) * zero(SetSemiring{Int}) == zero(SetSemiring{Int})
    @test SetSemiring([2]) * SetSemiring([1]) == SetSemiring([2])
end