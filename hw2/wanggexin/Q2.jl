

# 定义并集操作 ⊕
function ⊕(s::Set{Int}, t::Set{Int})
    return s ∪ t
end

# 定义乘积操作 ⊙
function ⊙(s::Set{Int}, t::Set{Int})
    return Set(x * y for x in s for y in t)
end

# 加法单位元 0
const zero_set = Set{Int}()

# 乘法单位元 1
const one_set = Set([1])

# 测试用例
println("⊕({2}, {5, 4}) = ", ⊕(Set([2]), Set([5, 4])))
println("⊕({2}, {}) = ", ⊕(Set([2]), zero_set))
println("⊙({2}, {5, 4}) = ", ⊙(Set([2]), Set([5, 4])))
println("⊙({2}, {}) = ", ⊙(Set([2]), zero_set))
println("⊙({2}, {1}) = ", ⊙(Set([2]), one_set))

# ⊕({2}, {5, 4}) = Set([5, 4, 2])
# ⊕({2}, {}) = Set([2])
# ⊙({2}, {5, 4}) = Set([10, 8])
# ⊙({2}, {}) = Set{Int64}()
# ⊙({2}, {1}) = Set([2])