using LinearAlgebra
using Test
using BenchmarkTools
include("main.jl")

@testset "lufact with pivot" begin
    n = 5
    A = randn(n, n)
    L, U, P = mylufact_pivot!(copy(A))
    pmat = zeros(Int, n, n)
    setindex!.(Ref(pmat), 1, 1:n, P)
    @test L ≈ lu(A).L
    @test U ≈ lu(A).U
    @test pmat * A ≈ L * U
end

n=100
a=randn(n, n)
@btime lufact_pivot!(copy(a))
@btime mylufact_pivot!(copy(a))
L, U, P = lufact_pivot!(copy(a))
L1, U1, P1 = mylufact_pivot!(copy(a))

@test L ≈ L1
@test U ≈ U1
@test P ≈ P1

U = [1.0 2.0 3.0;
     0.0 4.0 5.0;
     0.0 0.0 6.0]

b = [7.0, 8.0, 9.0]

x = back_substitution(U, b)

@test U * x ≈ b