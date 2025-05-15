### 2. (Reverse mode AD - Optional)
using Enzyme, Optim, LinearAlgebra, Test

# Define the graph
vertices = collect(1:10)
edges = [(1, 2), (1, 3),
         (2, 3), (2, 4), (2, 5), (2, 6),
         (3, 5), (3, 6), (3, 7),
         (4, 5), (4, 8),
         (5, 6), (5, 8), (5, 9),
         (6, 7), (6, 8), (6, 9),
         (7, 9), (8, 9), (8, 10), (9, 10)]

n = length(vertices)

# Identify non-edges
# Create a set of existing edges (handling both directions) for faster lookup
edge_set = Set([(min(u, v), max(u, v)) for (u, v) in edges])
non_edges = [(u, v) for u in vertices for v in vertices if u < v && !((u, v) in edge_set)]

# Initialize vertex positions randomly
# pos is a 1D array: [x1, y1, x2, y2, ..., xn, yn]
pos = rand(2n) .* 2.0 .- 1.0 # Initialize positions roughly in [-1, 1]^2

# Define the loss function
# It penalizes:
# - edges with distance >= 1
# - non-edges with distance <= 1
# - (Optional, from example) vertices far from the origin
function loss(pos)
    loss_val = 0.0

    # Penalty for edges being too far (> 1)
    for (u, v) in edges
        # Vertices are 1-indexed, pos array is 0-indexed logically (2u-1, 2u for u)
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += 100.0 * max(0.0, dist - 1.0)^2 # Use 100.0 for Float64
    end

    # Penalty for non-edges being too close (< 1)
    for (u, v) in non_edges
        dx = pos[2u-1] - pos[2v-1]
        dy = pos[2u] - pos[2v]
        dist = sqrt(dx^2 + dy^2)
        loss_val += 100.0 * max(0.0, 1.0 - dist)^2 # Use 100.0 for Float64
    end

    # Optional: Penalty for vertices being far from the origin
    # This is not strictly required for unit-disk embedding definition
    # but can help prevent the entire configuration from drifting.
    # Let's keep it as it was in the provided example structure,
    # but reducing the weight as it's less important than edge constraints.
    for i in 1:n
        x, y = pos[2i-1], pos[2i]
        r = sqrt(x^2 + y^2)
        # Consider penalizing distances significantly larger than, say, n/sqrt(n)
        # Or just keep the example's simple origin pull/push
        # loss_val += 1.0 * max(0.0, r - 5.0)^2 # Penalize if center drifts far
        # The example penalizes r > 1, which forces vertices into a disk of radius 1.
        # This might be too restrictive if the graph needs a larger area.
        # Let's use a weaker origin penalty if the graph goes far out.
        loss_val += 1.0 * max(0.0, r - 5.0)^2 # A weaker penalty for being too far out
    end


    return loss_val
end

# Define the gradient function using Enzyme.jl
# This function modifies the `grad` array in-place
function grad_loss!(grad, pos)
    grad .= 0.0 # Reset the gradient array
    # Compute the gradient of loss with respect to pos
    # Reverse mode AD: differentiate the scalar output (loss) w.r.t. the vector input (pos)
    autodiff(Enzyme.Reverse, loss, Active, Duplicated(pos, grad))
    return nothing # Function modifies grad in-place
end

# Run the optimization
println("Starting optimization...")
result = optimize(loss, grad_loss!, pos, LBFGS(),
                  Optim.Options(show_trace=true, iterations=3000, g_tol=1e-8, store_trace=true)) # Increased iterations and slightly looser g_tol

println("\nOptimization finished.")
println("Result: ", result)
println("Final Loss: ", Optim.minimum(result))

# Extract the optimized positions
optimized_pos = Optim.minimizer(result)

# Convert the flat array back to a list of (x, y) pairs for easier access
embedding = [(optimized_pos[2i-1], optimized_pos[2i]) for i in 1:n]

# Helper function to calculate distance between two vertices in the embedding
function distance(u, v, embedding)
    p_u = embedding[u]
    p_v = embedding[v]
    dx = p_u[1] - p_v[1]
    dy = p_u[2] - p_v[2]
    return sqrt(dx^2 + dy^2)
end

# Validate the unit-disk embedding properties
println("\nValidating embedding...")

# Define tolerances for validation. Optimization finds approximate solutions.
edge_tolerance = 0.05
non_edge_tolerance = 0.05

@testset "Unit-disk embedding validation" begin
    println("Checking edge distances (should be <= 1 + tolerance)...")
    violations_edge = 0
    for (u, v) in edges
        dist = distance(u, v, embedding)
        if dist > 1.0 + edge_tolerance
            println("  Violation: Edge ($u, $v) distance = $dist (expected <= $(1.0 + edge_tolerance))")
            violations_edge += 1
        end
        @test dist ≤ 1.0 + edge_tolerance
    end
    println("Edge checks complete. Violations: $violations_edge")

    println("Checking non-edge distances (should be >= 1 - tolerance)...")
    violations_non_edge = 0
    for (u, v) in non_edges
        dist = distance(u, v, embedding)
         if dist < 1.0 - non_edge_tolerance
             println("  Violation: Non-edge ($u, $v) distance = $dist (expected >= $(1.0 - non_edge_tolerance))")
             violations_non_edge += 1
         end
        @test dist ≥ 1.0 - non_edge_tolerance
    end
     println("Non-edge checks complete. Violations: $violations_non_edge")
end

println("\nEmbedding coordinates:")
for i in 1:n
    println("Vertex $i: $(embedding[i])")
end

