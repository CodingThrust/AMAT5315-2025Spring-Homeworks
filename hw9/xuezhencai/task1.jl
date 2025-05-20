using JuMP
using GLPK
using Graphs

# 构建 Petersen 图
g = PetersenGraph()
n = nv(g)

model = Model(GLPK.Optimizer)
@variable(model, x[1:n], Bin)

# 独立集约束：边两端不能都选
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
