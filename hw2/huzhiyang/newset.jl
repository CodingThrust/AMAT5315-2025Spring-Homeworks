# set definition
function ⊕(s::Set{Int}, t::Set{Int})
    return union(s, t)
end

function ⊙(s::Set{Int}, t::Set{Int})
    return Set([a * b for a in s for b in t])
end

setzero = Set{Int}()
setone = Set([1])

# test cases
@assert ⊕(Set([2]), Set([5,4])) == Set([2,4,5])
@assert ⊕(Set([5,4]), Set([2])) == Set([2,4,5])
@assert ⊕(Set([2]), setzero) == Set([2])
@assert ⊙(Set([2]), Set([5,4])) == Set([10,8])
@assert ⊙(Set([5,4]), Set([2])) == Set([10,8])
@assert ⊙(Set([2]), setzero) == Set{Int}()
@assert ⊙(Set([2]), setone) == Set([2])

println("pass test")