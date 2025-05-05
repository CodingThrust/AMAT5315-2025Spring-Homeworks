using Pkg
Pkg.activate("./hw10/zhaohui_zhi")
Pkg.instantiate()
using FiniteDifferences, ForwardDiff, Enzyme, Optim, LinearAlgebra, Graphs

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

grad_fdm = central_fdm(5, 1)(z -> poor_besselj(ν, z), z)
# => 0.22389077914123828

# ForwardDiff.jl
grad_forward = ForwardDiff.derivative(z -> poor_besselj(ν, z), z)
# => 0.22389077914123567

# Enzyme.jl
grad_enzyme = autodiff(Enzyme.Reverse, z -> poor_besselj(ν, z), Active, Active(z))[1][1]

# === #
vertices = collect(1:10)
edges = Edge.([(1, 2), (1, 3),
	(2, 3), (2, 4), (2, 5), (2, 6),
	(3, 5), (3, 6), (3, 7),
	(4, 5), (4, 8),
	(5, 6), (5, 8), (5, 9),
	(6, 7), (6, 8), (6, 9),
	(7,9), (8, 9), (8, 10), (9, 10)])
graph= SimpleGraph(edges)