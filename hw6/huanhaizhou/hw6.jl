using Pkg
Pkg.activate("./hw6/huanhaizhou")
Pkg.instantiate()

# Problem 1
using SparseArrays, Test

rowindices = [3, 1, 1, 4, 5]
colindices = [1, 2, 3, 3, 4]
data = [0.799, 0.942, 0.848, 0.164, 0.637]

sp = sparse(rowindices, colindices, data, 5, 5)

@testset "HW6 Problem 1: Sparse Matrix Construction" begin
    @test sp.colptr == [1, 2, 3, 5, 6, 6]
    @test sp.rowval == [3, 1, 1, 4, 5]
    @test sp.nzval == [0.799, 0.942, 0.848, 0.164, 0.637]
    @test sp.m == 5
    @test sp.n == 5
end



# Problem 2
using Graphs, Random, KrylovKit, LinearAlgebra

Random.seed!(42)
g = random_regular_graph(100000, 3)

n = nv(g)  # Number of vertices
A = adjacency_matrix(g)  # Adjacency matrix
D = Diagonal(fill(3, n))  # Degree matrix (diagonal with all entries 3)
L = Matrix(D - A)  # Laplacian matrix
L_sparse = sparse(L)
eigenvalues, eigenvectors = eigsolve(L_sparse, randn(size(L_sparse, 1)), 1, :SR)

num_connected_components = count(x -> abs(x) < 1e-6, eigenvalues)
@info "Number of connected components: $num_connected_components" # 1


# Problem 3

using LinearAlgebra

function restarting_lanczos(A, q1, s; max_restarts=5, tol=1e-10)
    n = size(A, 1)
    θ1_prev = 0.0
    q1 = normalize(q1)

    for restart in 1:max_restarts
        # Initialize Lanczos vectors and coefficients
        Q = zeros(n, s)
        α = zeros(s)
        β = zeros(s-1)
        Q[:, 1] = q1
        
        # Perform s steps of the Lanczos algorithm
        for j in 1:s-1
            # Compute A*q_j
            v = A * Q[:, j]
            
            # Compute α_j = q_j'*A*q_j
            α[j] = real(dot(Q[:, j], v))
            
            # Orthogonalization against previous vectors
            v = v .- α[j] .* Q[:, j]
            if j > 1
                v = v .- β[j-1] .* Q[:, j-1]
            end
            
            # Compute β_j = ||v||
            β[j] = norm(v)
            
            # Check for early convergence
            if β[j] < tol
                # Shrink matrices to correct size
                Q = Q[:, 1:j]
                α = α[1:j]
                β = β[1:j-1]
                s = j
                break
            end
            
            # Normalize the next Lanczos vector
            Q[:, j+1] = v ./ β[j]
        end
        
        # Set final α value (not computed in the loop)
        if s > 1
            v = A * Q[:, s]
            α[s] = real(dot(Q[:, s], v))
        end

        # Form tridiagonal matrix and compute its eigendecomposition
        Ts = diagm(0 => α[1:s], 1 => β[1:s-1], -1 => β[1:s-1])
        F = eigen(Ts)
        θ = real(F.values)
        U = F.vectors
        
        # Find largest eigenvalue and corresponding eigenvector
        idx = argmax(θ)
        θ1 = θ[idx]
        q1_new = Q[:, 1:s] * U[:, idx]
        q1_new = normalize(q1_new)  # Ensure unit vector

        # Check for convergence
        if abs(θ1 - θ1_prev) < tol
            return θ1, q1_new
        end
        
        # Update for next restart
        θ1_prev = θ1
        q1 = q1_new
    end
    
    # Return best approximation if max_restarts reached
    return θ1_prev, q1
end

using Random
Random.seed!(42)

@testset "HW6 Problem 3: Restarting Lanczos" begin
    # Create a symmetric random matrix
    n = 100
    A = randn(n, n)
    A = A + A'  # Make the matrix symmetric
    
    # Initialize with a random unit vector
    q1 = randn(n)
    q1 = normalize(q1)
    
    # Set parameters
    s = 20  # Subspace size
    
    # Run the algorithm
    θ1, v1 = restarting_lanczos(A, q1, s)
    
    # Compute the true largest eigenvalue for comparison
    θ_true = maximum(eigen(A).values)
    
    # Check that our approximation is close to the true eigenvalue
    @test isapprox(θ1, θ_true, atol=1e-6)
    
    # Verify that v1 is indeed an eigenvector
    @test norm(A*v1 - θ1*v1) < 1e-5
    
    # Check that v1 is normalized
    @test isapprox(norm(v1), 1.0, atol=1e-10)
end
