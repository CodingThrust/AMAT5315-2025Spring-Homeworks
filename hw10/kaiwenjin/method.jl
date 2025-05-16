using FiniteDifferences, ForwardDiff, Enzyme
using LinearAlgebra, Random, Test, Optim



function poor_besselj(ν, z::T; atol = eps(T)) where T
	k = 0
	s = (z / 2)^ν / factorial(ν)
	out = s
	while abs(s) > atol
		k += 1
		s *= (-1) / k / (k + ν) * (z / 2)^2
		out += s
	end
	return out
end

function set_graph(vertices::Vector{Int64}, edges::Vector{Tuple{Int64, Int64}})
    n = length(vertices)
    A = zeros(Int64, n, n)
    for edge in edges
        A[edge[1], edge[2]] = 1
        A[edge[2], edge[1]] = 1
    end
    return A
end

# define loss function
function loss(coords::Vector{Float64}, A::Matrix{Int64})
    total_loss = 0.0
    for i in 1:n
        for j in (i+1):n
            dist_sq = (coords[2*i - 1] - coords[2*j - 1])^2 + (coords[2*i] - coords[2*j])^2
            dist = sqrt(dist_sq)
            if A[i, j] == 1
                total_loss += relu(dist - 1.0)
            else
                total_loss += relu(1.0 - dist)
            end
        end
    end
    return total_loss
end

# ReLU
relu(x) = max(0, x)

# gradient
function ∇loss(x::Vector{Float64}, A::Matrix{Int64})
    n = length(x)
    grad_loss = zeros(n)
    autodiff(Enzyme.Reverse, t -> loss(t, A), Active, Duplicated(x, grad_loss))
    return grad_loss
end

