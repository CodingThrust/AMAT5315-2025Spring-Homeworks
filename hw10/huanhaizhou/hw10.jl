using Enzyme
using FiniteDifferences
using ForwardDiff
using Ipopt
using Optim
using Optimization, OptimizationMOI, OptimizationOptimJL, Ipopt

# Problem 1
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

FiniteDifferences.central_fdm(5, 1)(x -> poor_besselj(ν, x), z) # 0.22389077914123828
ForwardDiff.derivative(x -> poor_besselj(ν, x), z)  # 0.22389077914123567
Enzyme.autodiff(Reverse, x -> poor_besselj(ν, x), Active, Active(z))[1][1]  # 0.2238907791412357


# Problem 2
vertices = collect(1:10)
edges = [(1, 2), (1, 3),
	(2, 3), (2, 4), (2, 5), (2, 6),
	(3, 5), (3, 6), (3, 7),
	(4, 5), (4, 8),
	(5, 6), (5, 8), (5, 9),
	(6, 7), (6, 8), (6, 9),
	(7,9), (8, 9), (8, 10), (9, 10)]

all_pairs = collect([(i, j) for i in 1:10 for j in i+1:10])

disconnect_edges = setdiff(all_pairs, edges)

@inline relu(x) = max(x, 0)

@inline norm2(x::Tuple{T, T}) where T = x[1]^2 + x[2]^2

Base.:(-)(a::Tuple{T, T}, b::Tuple{T, T}) where T = (a[1] - b[1], a[2] - b[2])

function UDG_embedding_loss(coordinates::Vector{Tuple{T, T}}) where T
    loss = 0
    for edge in edges
        loss += relu(norm2(coordinates[edge[1]] - coordinates[edge[2]]) - 1)
    end
    
    for edge in disconnect_edges
        loss += relu(1 - norm2(coordinates[edge[1]] - coordinates[edge[2]]))
    end
    loss
end

coordinates = [(rand(), rand()) for _ in 1:10]
UDG_embedding_loss(coordinates)
