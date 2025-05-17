using JuMP,HiGHS,Test

function max_independent_set(n::Int, E::Vector{Tuple{Int,Int}})
    model = Model(HiGHS.Optimizer)
    @variable(model, x[1:n], Bin)
    @objective(model, Max, sum(x))
    for (u,v) in E
        @constraint(model, x[u] + x[v] <= 1)
    end
    @objective(model, Max, sum(x))
    optimize!(model)
    return value.(x)
end


### test

# generate petersen graph
function generate_petersen()
    edges = [
        (1, 2), (2, 3), (3, 4), (4, 5), (5, 1),   
        (6, 8), (8, 10), (10, 7), (7, 9), (9, 6), 
        (1, 6), (2, 7), (3, 8), (4, 9), (5, 10)   
    ]
    return edges
end

@testset "max_independent_set" begin
    edges = generate_petersen()
    n = 10
    x = max_independent_set(n, edges)
    @test sum(x) == 4
end

