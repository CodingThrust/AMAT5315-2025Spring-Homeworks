using Pkg
Pkg.activate("./hw9/huanhaizhou")
Pkg.instantiate()

using JuMP, HiGHS, Graphs

graph = smallgraph(:petersen)

model = Model(HiGHS.Optimizer)
n = nv(graph)
@variable(model, x[1:n], Bin)

@objective(model, Max, sum(x))

for e in edges(graph)
    @constraint(model, x[src(e)] + x[dst(e)] <= 1)
end
set_silent(model)
optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    @info "Maximum Independent Set Size: $(Int(objective_value(model)))"
    @info "Selected Vertices: $(findall(value.(x) .> 0.5))"
else
    @info "Solution not found"
end
