include("restarting_lanczos.jl")
using LinearAlgebra
using Test

A = Matrix{Float64}(reshape(ones(1000000), 1000, 1000))
@show ishermitian(A)
q1 = rand(1000)
q1=normalize(q1)

vals, vecs = eigen(A)

T,Q=restarting_lanczos(A, q1;iter=20)

@test eigen(Matrix(T)).values[end] ≈ vals[end] atol=1e-6
