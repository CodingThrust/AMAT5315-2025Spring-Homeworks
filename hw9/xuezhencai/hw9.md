# Homework 9
## Integer programming
```julia
using JuMP
using GLPK
using Graphs

g = PetersenGraph()
n = nv(g)

model = Model(GLPK.Optimizer)
@variable(model, x[1:n], Bin)

for e in edges(g)
    i, j = src(e), dst(e)
    @constraint(model, x[i] + x[j] <= 1)
end

@objective(model, Max, sum(x[i] for i in 1:n))
optimize!(model)

println("===== Maximum Independent Set on Petersen Graph =====")
println("Max set size: ", objective_value(model))
print("Selected vertices: ")
for i in 1:n
    if value(x[i]) > 0.5
        print("$(i) ")
    end
end
println()
```
```julia
===== Maximum Independent Set on Petersen Graph =====

Max set size: 4.0

Selected vertices: 
1 4 7 8 
```