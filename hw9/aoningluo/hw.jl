1.
using JuMP
using HiGHS
using GraphRecipes
using Plots

function solve_petersen_mis()
    edges = [
        (1,2), (1,5), (1,6),
        (2,3), (2,7),
        (3,4), (3,8),
        (4,5), (4,9),
        (5,10),
        (6,7), (6,10),
        (7,8),
        (8,9),
        (9,10)
    ]
    model = Model(HiGHS.Optimizer)
    set_silent(model)  
 
    @variable(model, x[1:10], Bin)
    
    for (i,j) in edges
        @constraint(model, x[i] + x[j] <= 1)
    end

    @objective(model, Max, sum(x))

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        solution = round.(Int, value.(x))
        independent_set = findall(==(1), solution)
        set_size = length(independent_set)

        is_valid = true
        for (i,j) in edges
            if solution[i] + solution[j] > 1
                is_valid = false
                break
            end
        end

        visualize_petersen(edges, independent_set)
        
        return independent_set
    else
        error("No optimal solution found")
    end
end

function visualize_petersen(edges, independent_set)
    n = 10
    adj = [Int[] for _ in 1:n]
    for (i,j) in edges
        push!(adj[i], j)
        push!(adj[j], i)
    end
    
    nodecolor = [i ∈ independent_set ? :red : :lightblue for i in 1:n]
    
    plt = graphplot(adj, 
                   names=1:10,
                   nodecolor=nodecolor,
                   nodesize=0.2,
                   edgecolor=:black,
                   fontsize=10,
                   title="Petersen Graph (Max Independent Set)",
                   titlefontsize=12)
    
    display(plt)
    savefig("petersen_mis.png")
end

solve_petersen_mis()