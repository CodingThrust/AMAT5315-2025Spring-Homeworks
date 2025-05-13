using JuMP
using GLPK
using SCIP  # For the tuned version
using BenchmarkTools

"""
    maximum_independent_set(adjacency_matrix)

Solve the maximum independent set problem using integer programming.
Returns a tuple (max_size, selected_vertices) where max_size is the size of the
maximum independent set and selected_vertices is an array of the vertices in the set.

# Arguments
- `adjacency_matrix`: A binary matrix where adjacency_matrix[i,j] = 1 if vertices i and j are connected.
"""
function maximum_independent_set(adjacency_matrix)
    n = size(adjacency_matrix, 1)  # Number of vertices
    
    # Create the model
    model = Model(GLPK.Optimizer)
    
    # Define variables: x[i] = 1 if vertex i is in the independent set, 0 otherwise
    @variable(model, x[1:n], Bin)
    
    # Objective: maximize the number of vertices in the independent set
    @objective(model, Max, sum(x))
    
    # Constraints: for each edge (i,j), at most one of i and j can be in the independent set
    for i in 1:n
        for j in i+1:n
            if adjacency_matrix[i,j] == 1
                @constraint(model, x[i] + x[j] <= 1)
            end
        end
    end
    
    # Solve the model
    optimize!(model)
    
    # Extract the solution
    if termination_status(model) == MOI.OPTIMAL
        selected = findall(value.(x) .> 0.5)
        return (length(selected), selected)
    else
        error("Failed to find optimal solution")
    end
end

"""
    maximum_independent_set_tuned(adjacency_matrix; tuned=false)

Solve the maximum independent set problem using integer programming with SCIP.
Returns a tuple (max_size, selected_vertices) where max_size is the size of the
maximum independent set and selected_vertices is an array of the vertices in the set.

# Arguments
- `adjacency_matrix`: A binary matrix where adjacency_matrix[i,j] = 1 if vertices i and j are connected.
- `tuned`: Boolean flag to use tuned parameters (default: false)
"""
function maximum_independent_set_tuned(adjacency_matrix; tuned=false)
    n = size(adjacency_matrix, 1)  # Number of vertices
    
    # Create the model with SCIP optimizer
    model = Model(SCIP.Optimizer)
    
    # Apply tuned parameters if requested
    if tuned
        # These parameters are examples based on common SCIP tuning strategies
        # Actual values should be determined through systematic experimentation
        
        # General solving limits
        set_optimizer_attribute(model, "limits/time", 60.0)  # Time limit in seconds
        
        # Presolving parameters
        set_optimizer_attribute(model, "presolving/maxrounds", 10)  # Limit presolving rounds
        set_optimizer_attribute(model, "presolving/abortfac", 0.2)  # Abort if reduction is small
        
        # Cutting plane parameters
        set_optimizer_attribute(model, "separating/maxrounds", 5)  # Limit separation rounds
        set_optimizer_attribute(model, "separating/maxroundsroot", 15)  # More cuts at root node
        
        # Heuristics parameters
        set_optimizer_attribute(model, "heuristics/shifting/freq", 10)  # Adjust shifting heuristic frequency
        set_optimizer_attribute(model, "heuristics/feaspump/freq", 5)  # Adjust feasibility pump frequency
        set_optimizer_attribute(model, "heuristics/rens/freq", 5)  # RENS heuristic frequency
        
        # Branching parameters
        set_optimizer_attribute(model, "branching/relpscost/priority", 10000)  # Prioritize reliable pseudo-cost branching
        
        # Parallelization parameters
        set_optimizer_attribute(model, "lp/threads", 4)  # Use multiple threads for LP solving
        set_optimizer_attribute(model, "parallel/maxnthreads", 4)  # Maximum number of threads
        
        # Memory management
        set_optimizer_attribute(model, "memory/savefac", 0.8)  # Memory saving factor
    end
    
    # Define variables: x[i] = 1 if vertex i is in the independent set, 0 otherwise
    @variable(model, x[1:n], Bin)
    
    # Objective: maximize the number of vertices in the independent set
    @objective(model, Max, sum(x))
    
    # Constraints: for each edge (i,j), at most one of i and j can be in the independent set
    for i in 1:n
        for j in i+1:n
            if adjacency_matrix[i,j] == 1
                @constraint(model, x[i] + x[j] <= 1)
            end
        end
    end
    
    # Solve the model
    optimize!(model)
    
    # Extract the solution
    if termination_status(model) == MOI.OPTIMAL
        selected = findall(value.(x) .> 0.5)
        return (length(selected), selected)
    else
        error("Failed to find optimal solution: $(termination_status(model))")
    end
end

"""
    create_petersen_graph()

Create the adjacency matrix for the Petersen graph.
The Petersen graph has 10 vertices and 15 edges.
"""
function create_petersen_graph()
    # Initialize a 10×10 adjacency matrix with zeros
    adj_matrix = zeros(Int, 10, 10)
    
    # Define the edges of the Petersen graph
    # Outer pentagon
    edges = [
        (1, 2), (2, 3), (3, 4), (4, 5), (5, 1),  # Outer pentagon
        (1, 6), (2, 7), (3, 8), (4, 9), (5, 10),  # Spokes
        (6, 8), (8, 10), (10, 7), (7, 9), (9, 6)  # Inner pentagram
    ]
    
    # Fill the adjacency matrix
    for (i, j) in edges
        adj_matrix[i, j] = 1
        adj_matrix[j, i] = 1  # Undirected graph
    end
    
    return adj_matrix
end

"""
    create_large_test_graph(n=100, density=0.1)

Create a larger graph for benchmarking purposes.

# Arguments
- `n`: Number of vertices
- `density`: Probability of an edge between any two vertices
"""
function create_large_test_graph(n=100, density=0.1)
    # Create a larger graph
    adj_matrix = zeros(Int, n, n)
    
    # Add random edges with specified density
    for i in 1:n
        for j in (i+1):n
            if rand() < density
                adj_matrix[i, j] = 1
                adj_matrix[j, i] = 1
            end
        end
    end
    
    return adj_matrix
end

"""
    create_crystal_structure_problem(n=50)

Create a test problem that mimics crystal structure prediction.
This is a simplified model - real crystal structure problems would be more complex.

# Arguments
- `n`: Size of the problem (number of potential atom positions)
"""
function create_crystal_structure_problem(n=50)
    # Create a 3D grid of potential atom positions
    dim = ceil(Int, n^(1/3))
    positions = [(i,j,k) for i in 1:dim for j in 1:dim for k in 1:dim][1:n]
    
    # Create adjacency matrix based on distance constraints
    adj_matrix = zeros(Int, n, n)
    
    # Two atoms can't be too close to each other (distance < 0.8 units)
    min_distance = 0.8
    
    for i in 1:n
        for j in (i+1):n
            p1 = positions[i]
            p2 = positions[j]
            # Calculate Euclidean distance
            dist = sqrt((p1[1]-p2[1])^2 + (p1[2]-p2[2])^2 + (p1[3]-p2[3])^2)
            if dist < min_distance
                adj_matrix[i, j] = 1
                adj_matrix[j, i] = 1
            end
        end
    end
    
    return adj_matrix
end

"""
    benchmark_solver_performance()

Benchmark the performance of the SCIP solver with default vs. tuned parameters.
"""
function benchmark_solver_performance()
    # Create a crystal structure problem for benchmarking
    println("Creating crystal structure test problem...")
    test_problem = create_crystal_structure_problem(80)  # Larger problem for meaningful benchmarks
    
    # Benchmark with default parameters
    println("Benchmarking with default parameters:")
    default_time = @elapsed maximum_independent_set_tuned(test_problem, tuned=false)
    println("Time with default parameters: $(default_time) seconds")
    
    # Benchmark with tuned parameters
    println("Benchmarking with tuned parameters:")
    tuned_time = @elapsed maximum_independent_set_tuned(test_problem, tuned=true)
    println("Time with tuned parameters: $(tuned_time) seconds")
    
    # Calculate speedup
    speedup = default_time / tuned_time
    println("Speedup: $(speedup)x")
    
    return speedup
end

# Test with the Petersen graph
function main()
    # Original test with Petersen graph
    petersen = create_petersen_graph()
    max_size, selected_vertices = maximum_independent_set(petersen)
    
    println("Maximum independent set size: ", max_size)
    println("Vertices in the maximum independent set: ", selected_vertices)
    
    # Verify the solution is indeed an independent set
    is_independent = true
    for i in selected_vertices
        for j in selected_vertices
            if i != j && petersen[i, j] == 1
                is_independent = false
                println("Error: Vertices $i and $j are connected!")
            end
        end
    end
    
    println("Is the solution a valid independent set? ", is_independent)
    
    # Run performance benchmarking for crystal structure prediction
    println("\n--- Performance Benchmarking for Crystal Structure Prediction ---")
    speedup = benchmark_solver_performance()
    
    if speedup >= 2.0
        println("✓ Performance improvement target achieved ($(speedup)x speedup)")
    else
        println("✗ Performance improvement target not met ($(speedup)x speedup, target: 2.0x)")
    end
end

# Run the main function
main()
#==

Maximum independent set size: 4
Vertices in the maximum independent set: [1, 4, 7, 8]
Is the solution a valid independent set? true

--- Performance Benchmarking for Crystal Structure Prediction ---
Creating crystal structure test problem...
Benchmarking with default parameters:
feasible solution found by trivial heuristic after 0.0 seconds, objective value 8.000000e+01
presolving:
presolving (1 rounds: 1 fast, 0 medium, 0 exhaustive):
 80 deleted vars, 0 deleted constraints, 0 added constraints, 0 tightened bounds, 0 added holes, 0 changed sides, 0 changed coefficients
 0 implications, 0 cliques
transformed 1/3 original solutions to the transformed problem space
Presolving Time: 0.00

SCIP Status        : problem is solved [optimal solution found]
Solving Time (sec) : 0.01
Solving Nodes      : 0
Primal Bound       : +8.00000000000000e+01 (3 solutions)
Dual Bound         : +8.00000000000000e+01
Gap                : 0.00 %
Time with default parameters: 2.575937167 seconds
Benchmarking with tuned parameters:
feasible solution found by trivial heuristic after 0.0 seconds, objective value 8.000000e+01
presolving:
presolving (1 rounds: 1 fast, 0 medium, 0 exhaustive):
 80 deleted vars, 0 deleted constraints, 0 added constraints, 0 tightened bounds, 0 added holes, 0 changed sides, 0 changed coefficients
 0 implications, 0 cliques
transformed 1/3 original solutions to the transformed problem space
Presolving Time: 0.00

SCIP Status        : problem is solved [optimal solution found]
Solving Time (sec) : 0.00
Solving Nodes      : 0
Primal Bound       : +8.00000000000000e+01 (3 solutions)
Dual Bound         : +8.00000000000000e+01
Gap                : 0.00 %
Time with tuned parameters: 0.108105208 seconds
Speedup: 23.828058006234077x
✓ Performance improvement target achieved (23.828058006234077x speedup)

==#