using Pkg
Pkg.activate("./hw9/zhaohui_zhi")
Pkg.instantiate()
using JuMP, HiGHS, ProblemReductions, Graphs
using SCIP

graph = smallgraph(:petersen)
IS= IndependentSet(graph)


model = Model(HiGHS.Optimizer)
n = nv(graph)
@variable(model, x[1:n], Bin)

# 目标函数：最大化选中顶点数量
@objective(model, Max, sum(x))

# 约束条件：相邻顶点不能同时被选中
for e in edges(graph)
    @constraint(model, x[src(e)] + x[dst(e)] <= 1)
end

# 求解模型
optimize!(model)

# 输出结果
if termination_status(model) == MOI.OPTIMAL
    println("最大独立集大小: ", objective_value(model))
    selected = findall(value.(x) .> 0.5)
    println("选中的顶点: ", selected)
    
    # 验证结果
    println("\n验证选中的顶点是否无相邻边:")
    for v1 in selected, v2 in selected
        if v1 < v2 && has_edge(graph, v1, v2)
            error("顶点 $v1 和 $v2 存在冲突边！")
        end
    end
    println("验证通过：选中顶点无相邻边")
else
    println("未找到最优解")
end

#===#



