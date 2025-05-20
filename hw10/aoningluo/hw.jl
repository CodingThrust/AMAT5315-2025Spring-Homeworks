1.
using FiniteDifferences
using ForwardDiff
using Enzyme
using SpecialFunctions
using Test

function poor_besselj(v, z::T; atol=eps(T)) where T
    k = 0
    s = (z/2)^v / factorial(v)
    out = s
    while abs(s) > atol
        k += 1
        s *= (-1) / k / (k + v) * (z/2)^2
        out += s
    end
    return out
end

const test_z = 2.0
const test_v = 2
const atol = 1e-8

function finite_diff_grad()
    f(z) = poor_besselj(test_v, z; atol=atol)
    grad = central_fdm(5, 1)(f, test_z) 
    println("Finite Differences gradient: ", grad)
    return grad
end

function forward_diff_grad()
    f(z) = poor_besselj(test_v, z; atol=atol)
    grad = ForwardDiff.derivative(f, test_z)
    println("ForwardDiff gradient: ", grad)
    return grad
end

function enzyme_grad()
    f(z) = poor_besselj(test_v, z; atol=atol)
    grad = Enzyme.autodiff(Enzyme.Forward, f, test_z)[2]
    println("Enzyme gradient: ", grad)
    return grad
end

function verify_results(fd_grad, fwd_grad, enz_grad)
    @test isapprox(fd_grad, fwd_grad, rtol=0.01)
    @test isapprox(fwd_grad, enz_grad, rtol=0.01)
end

function main()
    gradients = (
        finite_diff_grad(),
        forward_diff_grad(),
        enzyme_grad()
    )
    
    verify_results(gradients...)

    return gradients
end

main()