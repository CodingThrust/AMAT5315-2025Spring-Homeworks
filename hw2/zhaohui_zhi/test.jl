using Test
using Random
using BenchmarkTools
using Profile

include("Tropical_Max-Plus_Algebra.jl")
include("Tropical_Sets_Algebra.jl")

A = rand(Tropical{Float64}, 100, 100)
B = rand(Tropical{Float64}, 100, 100)
@btime C = A * B # 2.066 ms
@profile for i in 1:10; A * B; end
Profile.print(format=:flat,mincount=10)


@testset "semiring algebra over sets" begin
    a=Tropical_Set(Set([2]))
    b=Tropical_Set(Set([5,4]))
    set_one=one(Tropical_Set{Int})
    set_zero=zero(Tropical_Set{Int})
    @test isapprox(a+b,b+a) & isapprox(a+b,Tropical_Set(Set([2,5,4])))
    @test isapprox(a+set_zero,a)
    @test isapprox(a*b, b*a) & isapprox(Tropical_Set(Set([10,8])),a*b)
    @test isapprox(a*set_zero,set_zero)
    @test isapprox(a*set_one,a)
end

