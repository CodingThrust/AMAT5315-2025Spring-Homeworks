1. (Integer programming) Use the integer programming for solving the maximum independent set problem. The maximum independent set problem is a well-known NP-complete problem that asks for the largest subset of vertices in a graph such that no two vertices in the subset are connected by an edge. Use the Petersen graph to construct a test case (its maximum independent set is 4). Hint: use a boolean variable $x_i$ to indicate whether the vertex $i$ is in the independent set.

    To find the maximum independent set using integer programming:

    1.  **Variables**: For each vertex $i$, define a binary variable $x_i$.

        $x_i = 1$ if vertex $i$ is in the independent set.

        $x_i = 0$ otherwise.

    2.  **Objective**: 
        Maximize the size of the independent set.

        Maximize $\sum x_i$

    3.  **Constraints**: If an edge $(u,v)$ exists, vertices $u$ and $v$ cannot both be in the independent set.
        For each edge $(u,v)$:
        $x_u + x_v \le 1$.

    This formulation models the problem. We test it on the Petersen graph.

    ```julia
    using Graphs
    using JuMP
    using HiGHS

    # 3. Define the Petersen graph using Graphs.jl
    graph = smallgraph(:petersen)
    adj = adjacency_matrix(graph) # Adjacency matrix
    num_vertices = nv(graph)      # Number of vertices

    # 4. Create the JuMP model
    model = Model(HiGHS.Optimizer)
    set_silent(model) # Suppress solver output

    # 5. Define variables
    # x[i] = 1 if vertex i is in the independent set, 0 otherwise
    @variable(model, x[1:num_vertices], Bin)

    # 6. Define the objective function
    # Maximize the number of vertices in the independent set
    @objective(model, Max, sum(x[i] for i in 1:num_vertices))

    # 7. Define constraints
    # For each edge (u,v), at most one of u or v can be in the set
    # Iterate through the upper triangle of the adjacency matrix to find edges
    for u in 1:num_vertices
        for v in (u+1):num_vertices # Avoid duplicate edges and self-loops
            if adj[u, v] == 1 # If there is an edge between u and v
                @constraint(model, x[u] + x[v] <= 1)
            end
        end
    end

    # 8. Solve the model
    optimize!(model)

    # 9. Display results
    println("Solver Termination Status: ", termination_status(model))

    if termination_status(model) == MOI.OPTIMAL
        mis_size = objective_value(model)
        println("Maximum Independent Set Size: ", Int(mis_size))

        selected_vertices = [i for i in 1:num_vertices if value(x[i]) > 0.5]
        println("Vertices in the Maximum Independent Set: ", selected_vertices)

        # Verification (optional)
        is_independent = true
        for u_idx in 1:length(selected_vertices)
            for v_idx in (u_idx+1):length(selected_vertices)
                u_val = selected_vertices[u_idx]
                v_val = selected_vertices[v_idx]
                if adj[u_val, v_val] == 1
                    println("Error: Vertices ", u_val, " and ", v_val, " are connected but both chosen.")
                    is_independent = false
                    break
                end
            end
            if !is_independent; break; end
        end
        if is_independent
            println("The found set is a valid independent set.")
        else
            println("The found set is NOT a valid independent set.")
        end

    else
        println("Optimal solution not found. Status: ", termination_status(model))
    end
    ```

    **output:**

        Maximum Independent Set Size: 4
        Vertices in the Maximum Independent Set: [1, 4, 7, 8]
        The found set is a valid independent set.