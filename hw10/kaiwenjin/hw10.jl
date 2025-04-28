include("method.jl")

##################################################
# 1.
##################################################
z = 2.0
ν = 2

# FiniteDifferences
grad_fd = grad(central_fdm(5, 1), z -> poor_besselj(ν, z), z)[1]
println("FiniteDifferences gradient: ", grad_fd)
# FiniteDifferences gradient: 0.22389077914123828

# ForwardDiff
grad_fdiff = ForwardDiff.derivative(z -> poor_besselj(ν, z), z)
println("ForwardDiff gradient: ", grad_fdiff)
# ForwardDiff gradient: 0.22389077914123567

# Enzyme
grad_enzyme = Enzyme.autodiff(Reverse, z -> poor_besselj(ν, z), Active, Active(z))[1][1]
println("Enzyme gradient: ", grad_enzyme)
# Enzyme gradient: 0.22389077914123567

# Test
@testset "Gradient Test" begin
	@test grad_fd ≈ grad_fdiff ≈ grad_enzyme
end
#=
Test Summary: | Pass  Total  Time
Gradient Test |    1      1  0.3s
Test.DefaultTestSet("Gradient Test", Any[], 1, false, false, true, 1.745826922255093e9, 1.745826922578865e9, false, "/Users/yui/projects/AMAT5315-2025Spring-Homeworks/hw10/kaiwenjin/hw10.jl")
=#


##################################################
# 2.
##################################################

vertices = collect(1:10)
edges = [(1, 2), (1, 3),
    (2, 3), (2, 4), (2, 5), (2, 6),
    (3, 5), (3, 6), (3, 7),
    (4, 5), (4, 8),
    (5, 6), (5, 8), (5, 9),
    (6, 7), (6, 8), (6, 9),
    (7, 9), (8, 9), (8, 10), (9, 10)]



A = set_graph(vertices, edges)
n = length(vertices)

# initialize coordinates
Random.seed!(123) 
initial_coords = rand(2 * n)

# optimize
result = optimize(x -> loss(x, A), x -> ∇loss(x, A), initial_coords, BFGS(); autodiff = :none, inplace = false)
xopt = result.minimizer
#=
20-element Vector{Float64}:
  1.6511621064345037
  0.9330643995558637
  1.0235394785546204
  1.0751897204649752
  1.1313520765703748
  0.39369595439648963
  0.1112535258437113
  ⋮
 -0.24954565744379664
  0.48053024194992044
  0.0893400323618835
 -0.13627938253108068
 -0.720297400710208
 -0.15405908841866892
 =#

#test
@testset "unit-disk embedding" begin
    flag = true
    for i in 1:n
        for j in (i+1):n
            d = sqrt((xopt[2*i-1] - xopt[2*j-1])^2 + (xopt[2*i] - xopt[2*j])^2)
            (A[i,j] == 1)&&(d>1)&&(flag = false)&&break
            (A[i,j] == 0)&&(d<1)&&(flag = false)&&break
        end
    end
    @test flag
end
#=
Test Summary:       | Pass  Total  Time
unit-disk embedding |    1      1  0.0s
Test.DefaultTestSet("unit-disk embedding", Any[], 1, false, false, true, 1.745830107814187e9, 1.745830107818669e9, false, "/Users/yui/projects/AMAT5315-2025Spring-Homeworks/hw10/kaiwenjin/hw10.jl")
=#


