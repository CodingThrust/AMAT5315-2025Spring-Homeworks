### 1. (Automatic differentiation)
using FiniteDifferences, ForwardDiff, Enzyme

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

# FiniteDifferences.jl
grad_fdm = central_fdm(5, 1)(z -> poor_besselj(ν, z), z)
# => 0.22389077914123828

# ForwardDiff.jl
grad_forward = ForwardDiff.derivative(z -> poor_besselj(ν, z), z)
# => 0.22389077914123567

# Enzyme.jl
grad_enzyme = autodiff(Enzyme.Reverse, z -> poor_besselj(ν, z), Active, Active(z))
# => (0.22389077914123567,)



### 2. (Reverse mode AD - Optional)
using Enzyme, Optim, LinearAlgebra, Test

vertices = collect(1:10)
edge = [(1, 2), (1, 3),
         (2, 3), (2, 4), (2, 5), (2, 6),
         (3, 5), (3, 6), (3, 7),
         (4, 5), (4, 8),
         (5, 6), (5, 8), (5, 9),
         (6, 7), (6, 8), (6, 9),
         (7, 9), (8, 9), (8, 10), (9, 10)]

non_edge = [(u, v) for u in vertices for v in vertices if u < v && !((u, v) in edge || (v, u) in edge)]

n = length(vertices)
pos = rand(2n) .* 0.5 .- 0.25  


function loss(pos)
    loss_val = 0.0
 
    for (u, v) in edge
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += 100 * max(0, dist - 1)^2  
    end
 
    for (u, v) in non_edge
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += 100 * max(0, 1 - dist)^2 
    end

    for i in 1:n
        x, y = pos[2i-1], pos[2i]
        r = sqrt(x^2 + y^2)
        loss_val += 10 * max(0, r - 1)^2  
    end
    return loss_val
end

function grad_loss!(grad, pos)
    grad .= 0.0
    autodiff(Enzyme.Reverse, loss, Active, Duplicated(pos, grad))
    return nothing
end


result = optimize(loss, grad_loss!, pos, LBFGS(),
                  Optim.Options(show_trace=true, iterations=2000, g_tol=1e-10))

optimized_pos = Optim.minimizer(result)
embedding = [(optimized_pos[2i-1], optimized_pos[2i]) for i in 1:n]


function distance(u, v, embedding)
    dx = embedding[u][1] - embedding[v][1]
    dy = embedding[u][2] - embedding[v][2]
    return sqrt(dx^2 + dy^2)
end




@testset "Unit-disk embedding validation" begin
    edge_tolerance = 0.05
    non_edge_tolerance = 0.05
    for (u, v) in edge
        dist = distance(u, v, embedding)
        @test dist ≤ 1 + edge_tolerance
    end
    # Check all non-edges are ≥ 1 - tolerance
    for (u, v) in non_edge
        dist = distance(u, v, embedding)
        @test dist ≥ 1 - non_edge_tolerance
    end
end
