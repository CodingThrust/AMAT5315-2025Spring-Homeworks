struct SetSemiring{T}
    set::Set{T}
    function SetSemiring(set::Set{T}) where T
        new{T}(set)
    end
end

SetSemiring(X::AbstractVector{T}) where T = SetSemiring(Set(X))

function Base.show(io::IO, s::SetSemiring)
    elements = sort(collect(s.set))  
    print(io, "{", join(elements, ", "), "}")
end

Base.:+(Y::SetSemiring{T}, Z::SetSemiring{T}) where T = SetSemiring(union(Y.set, Z.set))

Base.:*(Y::SetSemiring{T}, Z::SetSemiring{T}) where T = SetSemiring(Set([σ * τ for σ in Y.set, τ in Z.set]))

Base.zero(::Type{SetSemiring{T}}) where T = SetSemiring(Set{T}())
Base.zero(Y::SetSemiring{T}) where T = zero(SetSemiring{T})

Base.one(::Type{SetSemiring{T}}) where T = SetSemiring(Set{T}([one(T)]))
Base.one(Y::SetSemiring{T}) where T = one(SetSemiring{T})

Base.:(==)(Y::SetSemiring{T}, Z::SetSemiring{T}) where T = Y.set == Z.set

using Test
@testset "semiring set" begin
    @test SetSemiring([2]) + SetSemiring([5,4]) == SetSemiring([2, 4, 5])
    @test SetSemiring([2]) + zero(SetSemiring{Int}) == SetSemiring([2])
    @test SetSemiring([2]) * SetSemiring([5,4]) == SetSemiring([10, 8])
    @test SetSemiring([2]) * zero(SetSemiring{Int}) == zero(SetSemiring{Int})
    @test SetSemiring([2]) * SetSemiring([1]) == SetSemiring([2])
end