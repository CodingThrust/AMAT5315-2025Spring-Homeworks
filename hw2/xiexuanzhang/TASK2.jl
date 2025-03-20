struct SetSemiring{T}
    elements::Set{T}
    function SetSemiring(elements::Set{T}) where T
        new{T}(elements)
    end
end

SetSemiring(vec::AbstractVector{T}) where T = SetSemiring(Set(vec))

function Base.show(io::IO, s::SetSemiring)
    sorted_elements = sort(collect(s.elements))  
    print(io, "{", join(sorted_elements, ", "), "}")
end

Base.:+(a::SetSemiring{T}, b::SetSemiring{T}) where T = SetSemiring(union(a.elements, b.elements))

Base.:*(a::SetSemiring{T}, b::SetSemiring{T}) where T = SetSemiring(Set([x * y for x in a.elements for y in b.elements]))

Base.zero(::Type{SetSemiring{T}}) where T = SetSemiring(Set{T}())
Base.zero(s::SetSemiring{T}) where T = zero(SetSemiring{T})

Base.one(::Type{SetSemiring{T}}) where T = SetSemiring(Set{T}([one(T)]))
Base.one(s::SetSemiring{T}) where T = one(SetSemiring{T})

Base.:(==)(a::SetSemiring{T}, b::SetSemiring{T}) where T = a.elements == b.elements


using Test
@testset "semiring set" begin
    @test SetSemiring([2]) + SetSemiring([5, 4]) == SetSemiring([5, 4]) + SetSemiring([2]) == SetSemiring([2, 5, 4])
    @test SetSemiring([2]) + zero(SetSemiring{Int}) == SetSemiring([2])
    @test SetSemiring([2]) * SetSemiring([5, 4]) == SetSemiring([5, 4]) * SetSemiring([2]) == SetSemiring([10, 8])
    @test SetSemiring([2]) * zero(SetSemiring{Int}) == zero(SetSemiring{Int})
    @test SetSemiring([2]) * SetSemiring([1]) == SetSemiring([2])
end