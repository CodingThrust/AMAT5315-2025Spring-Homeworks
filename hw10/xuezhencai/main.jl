using FiniteDifferences
using ForwardDiff
using Enzyme
using LinearAlgebra
using Optim
using ForwardDiff

#task1
v = 2
z = 2.0

# Method 1: FiniteDifferences
fdm = central_fdm(5, 1)
∂fd = fdm(z -> poor_besselj_fixed(v, z), z)[1]
println("FiniteDifferences grad = ", ∂fd)

# Method 2: ForwardDiff
∂fw = ForwardDiff.derivative(z -> poor_besselj_fixed(v, z), z)
println("ForwardDiff grad       = ", ∂fw)

# Method 3: Enzyme
function bessel_j_wrapper(v::Int, z::Float64)
    return poor_besselj_fixed(v, z)
end

res = Enzyme.autodiff(Forward, bessel_j_wrapper, Const(v), Duplicated(z, 1.0))
∂enzyme = res[1]
println("Enzyme (Forward) grad  = ", ∂enzyme)

#task2
# ----------------------------
# Step 1: Define graph structure
# ----------------------------

vertices = collect(1:10)
edges = [
    (1, 2), (1, 3), (2, 3), (2, 4), (2, 5), (2, 6),
    (3, 5), (3, 6), (3, 7), (4, 5), (4, 8),
    (5, 6), (5, 8), (5, 9), (6, 7), (6, 8), (6, 9),
    (7, 9), (8, 9), (8, 10), (9, 10)
]

n = length(vertices)
edge_set = Set([(min(u, v), max(u, v)) for (u, v) in edges])
all_pairs = [(u, v) for u in vertices for v in vertices if u < v]
non_edges = [(u, v) for (u, v) in all_pairs if !((u, v) in edge_set)]

# ----------------------------
# Step 2: Define loss function
# ----------------------------

function loss(pos)
    loss_val = 0.0
    for (u, v) in edges
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += 100.0 * max(0.0, dist - 1.0)^2
    end
    for (u, v) in non_edges
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += 100.0 * max(0.0, 1.0 - dist)^2
    end
    for i in 1:n
        r = sqrt(pos[2i-1]^2 + pos[2i]^2)
        loss_val += 1.0 * max(0.0, r - 5.0)^2
    end
    return loss_val
end

# ----------------------------
# Step 3: Define gradient with Enzyme
# ----------------------------

function grad_loss!(grad, pos)
    grad .= 0.0
    Enzyme.autodiff(Enzyme.Reverse, loss, Enzyme.Active, Enzyme.Duplicated(pos, grad))
    return nothing
end

# ----------------------------
# Step 4: Run optimization
# ----------------------------

initial_pos = rand(2n) .* 2 .- 1  # [-1, 1]^2 random init
println("Starting optimization...")

result = optimize(loss, grad_loss!, initial_pos, LBFGS(),
    Optim.Options(iterations=3000, show_trace=true, g_tol=1e-8))

println("Optimization finished.")
println("Final Loss: ", Optim.minimum(result))

# ----------------------------
# Step 5: Post-process & validate
# ----------------------------

pos_opt = Optim.minimizer(result)
embedding = [(pos_opt[2i-1], pos_opt[2i]) for i in 1:n]

function distance(u, v)
    dx = embedding[u][1] - embedding[v][1]
    dy = embedding[u][2] - embedding[v][2]
    return sqrt(dx^2 + dy^2)
end

edge_tol = 0.05
non_edge_tol = 0.05

@testset "Unit Disk Embedding Validation" begin
    println("\n--- Edge checks (should be ≤ 1 + tol) ---")
    for (u, v) in edges
        d = distance(u, v)
        if d > 1.0 + edge_tol
            println("❌ Edge ($u, $v): $d > $(1.0 + edge_tol)")
        end
        @test d ≤ 1.0 + edge_tol
    end

    println("\n--- Non-edge checks (should be ≥ 1 - tol) ---")
    for (u, v) in non_edges
        d = distance(u, v)
        if d < 1.0 - non_edge_tol
            println("❌ Non-edge ($u, $v): $d < $(1.0 - non_edge_tol)")
        end
        @test d ≥ 1.0 - non_edge_tol
    end
end

println("\n=== Final Embedding Coordinates ===")
for i in 1:n
    println("Vertex $i → ", embedding[i])
end
