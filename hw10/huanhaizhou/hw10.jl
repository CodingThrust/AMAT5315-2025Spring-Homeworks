using Pkg
Pkg.activate("./hw10/huanhaizhou")
Pkg.instantiate()

using Enzyme
using FiniteDifferences
using ForwardDiff
using Optim
using Test

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

disjoint_edges = setdiff(collect([(i, j) for i in 1:10 for j in i+1:10]), edges)

@inline function distance(ux::T, uy::T, vx::T, vy::T) where T <: Real
    return sqrt((ux - vx)^2 + (uy - vy)^2)
end

@inline function distance(u::Tuple{T, T}, v::Tuple{T, T}) where T <: Real
    return distance(u[1], u[2], v[1], v[2])
end

function UDG_embedding_loss(coordinates::Vector{T}, edges::Vector{Tuple{Int, Int}}, disjoint_edges::Vector{Tuple{Int, Int}}) where T <: Real
    return sum(max(0, distance(coordinates[2u-1], coordinates[2u], coordinates[2v-1], coordinates[2v]) - 1) for (u, v) in edges) +
        sum(max(0, 1 - distance(coordinates[2u-1], coordinates[2u], coordinates[2v-1], coordinates[2v])) for (u, v) in disjoint_edges)
end

function grad_UDG_embedding_loss!(grad, coordinates::Vector{T}) where T <: Real
    grad .= 0.0
    autodiff(Enzyme.Reverse, coordinates->UDG_embedding_loss(coordinates, edges, disjoint_edges), Active, Duplicated(coordinates, grad))
    return nothing
end

@testset "HW10 Problem 2: Unit-disk Embedding" begin
    n = length(vertices)
    embedding_tolerance = 0.05
    loss_atol = 0.01
    trial = 10

    for _ in 1:trial
        coordinates = rand(2n) .- 0.5  

        result = optimize(coordinates->UDG_embedding_loss(coordinates, edges, disjoint_edges), grad_UDG_embedding_loss!, coordinates, LBFGS(),
                  Optim.Options(show_trace=false, iterations=2000, g_tol=1e-10))
        
        # UDG embedding found
        if abs(Optim.minimum(result)) < loss_atol
            optimized_coordinates = Optim.minimizer(result)
            embedding = [(optimized_coordinates[2i-1], optimized_coordinates[2i]) for i in 1:n]

            @info "UDG embedding found" embedding
            for (u, v) in edges
                @test distance(embedding[u], embedding[v]) ≤ 1 + embedding_tolerance
            end
            for (u, v) in disjoint_edges
                @test distance(embedding[u], embedding[v]) ≥ 1 - embedding_tolerance
            end

            return
        end
    end

    @warn "UDG embedding not found"
end 