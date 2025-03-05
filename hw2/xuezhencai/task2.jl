function ⊕(s::Set{Int}, t::Set{Int})
    return union(s, t)
end

function ⊙(s::Set{Int}, t::Set{Int})
    if isempty(t)
        return Set{Int}()
    else
        return Set([a * b for a in s for b in t])
    end
end

setzero = Set{Int}()
setone = Set([1])

using Test

@testset "Semiring Algebra Tests" begin
    @test ⊕(Set([2]), Set([5,4])) == Set([2,4,5])
    @test ⊕(Set([5,4]), Set([2])) == Set([2,4,5])
    @test ⊕(Set([2]), setzero) == Set([2])
    
    @test ⊙(Set([2]), Set([5,4])) == Set([10,8])
    @test ⊙(Set([5,4]), Set([2])) == Set([10,8])
    @test ⊙(Set([2]), setzero) == Set{Int}()
    @test ⊙(Set([2]), setone) == Set([2])
end

println("All tests passed!")