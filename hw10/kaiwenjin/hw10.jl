using FiniteDifferences, ForwardDiff, Enzyme
using LinearAlgebra, Random, Test


##################################################
# 1.
##################################################
function poor_besselj(ν, z::T; atol=eps(T)) where T
    k = 0
    s = (z/2)^ν / factorial(ν)
    out = s
    while abs(s) > atol
        k += 1
        s *= (-1) / k / (k+ν) * (z/2)^2
        out += s
    end
    out
end

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
grad_enzyme = Enzyme.autodiff(Reverse, z -> poor_besselj(ν, z), Active(z))
println("Enzyme gradient: ", grad_enzyme)
# Enzyme gradient: 0.22389077914123567

# Test
@testset "Gradient Test" begin
    @test grad_fd ≈ grad_fdiff ≈ grad_enzyme
end
