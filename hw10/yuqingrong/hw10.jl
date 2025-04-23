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
using Enzyme, Optim, LinearAlgebra

vertices = collect(1:10)
edge = [(1, 2), (1, 3),
         (2, 3), (2, 4), (2, 5), (2, 6),
         (3, 5), (3, 6), (3, 7),
         (4, 5), (4, 8),
         (5, 6), (5, 8), (5, 9),
         (6, 7), (6, 8), (6, 9),
         (7, 9), (8, 9), (8, 10), (9, 10)]

non_edges = [(u, v) for u in vertices for v in vertices if u < v && !((u, v) in edge || (v, u) in edge)]

n = length(vertices)
pos = rand(2n) .* 2 .- 1  


function loss(pos)
    loss_val = 0.0
    for (u, v) in edge
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += max(0, dist - 1)^2  
    end
    for (u, v) in non_edges
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += max(0, 1 - dist)^2 
    end
    return loss_val
end


function grad_loss!(grad, pos)
    grad .= 0.0
    autodiff(Enzyme.Reverse, loss, Active, Duplicated(pos, grad))
    return nothing
end


result = optimize(loss, grad_loss!, pos, LBFGS(), Optim.Options(show_trace=true))

optimized_pos = Optim.minimizer(result)

embedding = [(optimized_pos[2i-1], optimized_pos[2i]) for i in 1:n]

println("Unit-disk embedding coordinates:")
for (i, (x, y)) in enumerate(embedding)
    println("Vertex $i: ($x, $y)")
end
# => Vertex 1: (-0.8532574888909433, -1.174855295266971)
# => Vertex 2: (-0.3534104153471856, -0.5497262048359522)
# => Vertex 3: (-0.19971612104417055, -0.5766394659296381)
# => Vertex 4: (-0.16334541907617486, 0.664101319631093)
# => Vertex 5: (0.11931392109423278, -0.33241913855988153)
# => Vertex 6: (0.558538751081, -0.4541770060704471)
# => Vertex 7: (0.6954316145953644, 0.4550533346044638)
# => Vertex 8: (0.43972758792992045, -0.19040581275096352)
# => Vertex 9: (0.4500454104745883, 0.043107608004893806)
# => Vertex 10: (-0.7076849765587815, 0.17768557787584624)

