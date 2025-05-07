using Pkg
Pkg.activate("./hw10/zhaohui_zhi")
Pkg.instantiate()
using FiniteDifferences, ForwardDiff, Enzyme, Optim, LinearAlgebra, Graphs, Test

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
edge=[(1, 2), (1, 3),
(2, 3), (2, 4), (2, 5), (2, 6),
(3, 5), (3, 6), (3, 7),
(4, 5), (4, 8),
(5, 6), (5, 8), (5, 9),
(6, 7), (6, 8), (6, 9),
(7,9), (8, 9), (8, 10), (9, 10)]
edges = Edge.(edge)
graph= SimpleGraph(edges)


all_pairs = [(u, v) for u in 1:10 for v in u+1:10]
non_edges = [pair for pair in all_pairs if !(pair in edge)]


function loss(coords)
    loss_val = 0.0
    # 处理边：距离平方需 < 1
    for (u, v) in edge
        xu, yu = coords[2u-1], coords[2u]
        xv, yv = coords[2v-1], coords[2v]
        dx, dy = xu - xv, yu - yv
        d_sq = dx^2 + dy^2
        loss_val += max(0, d_sq - 1.0)^2
    end
    # 处理非边：距离平方需 > 1
    for (u, v) in non_edges
        xu, yu = coords[2u-1], coords[2u]
        xv, yv = coords[2v-1], coords[2v]
        dx, dy = xu - xv, yu - yv
        d_sq = dx^2 + dy^2
        loss_val += max(0, 1.0 - d_sq)^2
    end
    return loss_val
end

function grad_loss!(grad, coords)
    grad .= 0.0
    autodiff(Enzyme.Reverse, loss, Active, Duplicated(coords, grad))
    return nothing
end

initial_coords=rand(2 * length(vertices)) .-0.5

opt = optimize(loss, grad_loss!, initial_coords, LBFGS(),
                  Optim.Options(show_trace=true, iterations=2000, g_tol=1e-10))

mini_coords = Optim.minimizer(opt)
coordinates = [(mini_coords[2i-1], mini_coords[2i]) for i in 1:length(vertices)]

x = [c[1] for c in coordinates]
y = [c[2] for c in coordinates]
scatter(x, y, label="Vertices", markersize=5)
for (u, v) in edge
    plot!([x[u], x[v]], [y[u], y[v]], color=:blue, label="")
end
display(plot!())

# 输出坐标
for (i, (x, y)) in enumerate(coordinates)
    println("Vertex $i: ($x, $y)")
end

function distance(u, v, coordinates)
    dx = coordinates[u][1] - coordinates[v][1]
    dy = coordinates[u][2] - coordinates[v][2]
    return sqrt(dx^2 + dy^2)
end


@testset "Unit-disk coordinates validation" begin
    edge_tolerance = 0.05
    non_edge_tolerance = 0.05
    for (u, v) in edge
        dist = distance(u, v, coordinates)
        @test dist ≤ 1 + edge_tolerance
    end

    for (u, v) in non_edges
        dist = distance(u, v, coordinates)
        @test dist ≥ 1 - non_edge_tolerance
    end
end