struct CollectionAlgebra{T}
    collection::Set{T}
    function CollectionAlgebra(collection::Set{T}) where T
        new{T}(collection)
    end
end

CollectionAlgebra(x::AbstractVector{T}) where T = CollectionAlgebra(Set(x))

function Base.show(io::IO, c::CollectionAlgebra)
    elements = sort(collect(c.collection))  
    print(io, "{", join(elements, ", "), "}")
end

Base.:+(a::CollectionAlgebra{T}, b::CollectionAlgebra{T}) where T = CollectionAlgebra(union(a.collection, b.collection))

Base.:*(a::CollectionAlgebra{T}, b::CollectionAlgebra{T}) where T = CollectionAlgebra(Set([σ * τ for σ in a.collection for τ in b.collection]))

Base.zero(::Type{CollectionAlgebra{T}}) where T = CollectionAlgebra(Set{T}())
Base.zero(c::CollectionAlgebra{T}) where T = zero(CollectionAlgebra{T})

Base.one(::Type{CollectionAlgebra{T}}) where T = CollectionAlgebra(Set{T}([one(T)]))
Base.one(c::CollectionAlgebra{T}) where T = one(CollectionAlgebra{T})

Base.:(==)(a::CollectionAlgebra{T}, b::CollectionAlgebra{T}) where T = a.collection == b.collection


using Test
@testset "algebra collection" begin
    @test CollectionAlgebra([2]) + CollectionAlgebra([5,4]) == CollectionAlgebra([5,4]) + CollectionAlgebra([2]) ==  CollectionAlgebra([2,5,4])
    @test CollectionAlgebra([2]) + zero(CollectionAlgebra{Int}) == CollectionAlgebra([2])
    @test CollectionAlgebra([2]) * CollectionAlgebra([5,4]) == CollectionAlgebra([5,4]) * CollectionAlgebra([2]) == CollectionAlgebra([10,8])
    @test CollectionAlgebra([2]) * zero(CollectionAlgebra{Int}) == zero(CollectionAlgebra{Int})
    @test CollectionAlgebra([2]) * CollectionAlgebra([1]) == CollectionAlgebra([2])
end