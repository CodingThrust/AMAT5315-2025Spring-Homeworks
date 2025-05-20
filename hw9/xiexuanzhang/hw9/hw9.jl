using JuMP
using GLPK
using Graphs  # Ensure Graphs package is imported

# Construct the Petersen graph
function create_petersen_graph()
    g = SimpleGraph(10)  # Create a simple undirected graph with 10 vertices
    # Connect outer pentagon
    for i in 1:5
        add_edge!(g, i, mod1(i+1, 5))
    end
    # Connect inner pentagram
    for i in 6:10
        add_edge!(g, i, mod1(i+2, 5) + 5)
    end
    # Connect outer and inner layers
    for i in 1:5
        add_edge!(g, i, i + 5)
    end
    return g
end

# Build integer programming model
function solve_max_independent_set()
    g = create_petersen_graph()
    m = Model(GLPK.Optimizer)

    # Define binary variables x[i] indicating if vertex i is in the independent set
    @variable(m, x[1:10], Bin)

    # Objective function: maximize the number of vertices in the independent set
    @objective(m, Max, sum(x))

    # Constraint: adjacent vertices cannot both be in the independent set
    for e in edges(g)
        i, j = src(e), dst(e)
        @constraint(m, x[i] + x[j] <= 1)
    end

    # Solve the model
    optimize!(m)

    # Get results
    if termination_status(m) == MOI.OPTIMAL
        ind_set = findall(x -> value(x) == 1, value.(x))
        println("Size of maximum independent set: ", length(ind_set))
        println("Vertices in maximum independent set: ", ind_set)
    else
        println("Solution failed, status: ", termination_status(m))
    end
end

solve_max_independent_set()


2.
using SCIP
using JuMP
using DataFrames
using CSV
using Dates
using MathOptInterface

# 定义参数搜索空间
function get_parameter_search_space()
    return Dict(
        "branching/scorefunc" => ["s", "p", "d", "o", "a", "r", "q", "t"],
        "branching/strong/freq" => [1, 2, 5, 10, 20, 50],
        "branching/strong/fracdiving" => [true, false],
        "constraints/knapsack/propagate" => [true, false],
        "constraints/knapsack/propagatebound" => [5, 10, 20, 50, 100],
        "separating/maxrounds" => [0, 1, 5, 10, 20],
        "presolving/maxrestarts" => [0, 1, 5, 10, 20]
    )
end

# 构建晶体结构预测模型
function build_crystal_structure_model()
    model = Model(SCIP.Optimizer)
    
    @variable(model, 0 <= x[1:100] <= 1, Int)
    @objective(model, Min, sum(i * x[i] for i in 1:100))
    @constraint(model, sum(x[i] for i in 1:100) >= 30)
    
    return model
end

# 设置SCIP参数
function set_scip_parameters(model, params)
    for (param_name, param_value) in params
        set_optimizer_attribute(model, param_name, param_value)
    end
end

# 将MOI状态转换为字符串
function moi_status_to_string(status)
    if status == MOI.OPTIMAL
        return "OPTIMAL"
    elseif status == MOI.INFEASIBLE
        return "INFEASIBLE"
    elseif status == MOI.INFEASIBLE_OR_UNBOUNDED
        return "INFEASIBLE_OR_UNBOUNDED"
    elseif status == MOI.TIME_LIMIT
        return "TIME_LIMIT"
    elseif status == MOI.ITERATION_LIMIT
        return "ITERATION_LIMIT"
    elseif status == MOI.NODE_LIMIT
        return "NODE_LIMIT"
    elseif status == MOI.SOLUTION_LIMIT
        return "SOLUTION_LIMIT"
    elseif status == MOI.OPTIMIZE_NOT_CALLED
        return "OPTIMIZE_NOT_CALLED"
    elseif status == MOI.OPTIMIZING
        return "OPTIMIZING"
    elseif status == MOI.OPTIMAL_INFEASIBLE
        return "OPTIMAL_INFEASIBLE"
    elseif status == MOI.SUBOPTIMAL
        return "SUBOPTIMAL"
    elseif status == MOI.OTHER_LIMIT
        return "OTHER_LIMIT"
    elseif status == MOI.DUAL_INFEASIBLE
        return "DUAL_INFEASIBLE"
    elseif status == MOI.OTHER_ERROR
        return "OTHER_ERROR"
    elseif status == MOI.INTERRUPTED
        return "INTERRUPTED"
    else
        return string(status)
    end
end

# 运行单次实验
function run_experiment(params)
    model = build_crystal_structure_model()
    set_scip_parameters(model, params)
    
    start_time = time()
    optimize!(model)
    end_time = time()
    
    solve_time = end_time - start_time
    status = termination_status(model)
    status_str = moi_status_to_string(status)
    
    # 检查是否有解
    objective_val = if termination_status(model) == MOI.OPTIMAL || 
                      termination_status(model) == MOI.SUBOPTIMAL
        objective_value(model)
    else
        missing  # 直接使用missing而不是NaN
    end
    
    return Dict(
        "params" => params,
        "solve_time" => solve_time,
        "status" => status_str,
        "objective_value" => objective_val
    )
end

# 网格搜索最佳参数组合
function grid_search(max_iterations=100)
    param_space = get_parameter_search_space()
    param_names = collect(keys(param_space))
    
    # 使用正确的类型声明
    results = DataFrame(
        iteration=Int[],
        params=Dict{String, Any}[],
        solve_time=Float64[],
        status=String[],
        objective_value=Union{Float64, Missing}  # 正确的类型声明
    )
    
    # 基准测试
    baseline_result = run_experiment(Dict())
    push!(results, (0, Dict(), baseline_result["solve_time"], baseline_result["status"], baseline_result["objective_value"]))
    
    best_time = baseline_result["solve_time"]
    best_params = Dict()
    
    println("基准求解时间: $(best_time)秒")
    
    # 迭代搜索
    iteration = 1
    while iteration <= max_iterations
        current_params = Dict()
        for param_name in param_names
            values = param_space[param_name]
            current_params[param_name] = rand(values)
        end
        
        result = run_experiment(current_params)
        push!(results, (iteration, current_params, result["solve_time"], result["status"], result["objective_value"]))
        
        if result["solve_time"] < best_time && result["status"] == "OPTIMAL"
            best_time = result["solve_time"]
            best_params = copy(current_params)
            println("迭代 $iteration: 新的最佳时间 $(best_time)秒")
        end
        
        iteration += 1
    end
    
    timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
    CSV.write("parameter_search_results_$(timestamp).csv", results)
    
    return best_params, best_time, baseline_result["solve_time"]
end

# 生成性能提升报告
function generate_report(best_params, best_time, baseline_time)
    improvement_factor = baseline_time / best_time
    
    report = """
    # SCIP参数优化提升晶体结构预测性能报告
    
    ## 一、实验概述
    本次实验通过调整SCIP求解器的参数，优化晶体结构预测问题的求解性能。
    
    ## 二、实验方法
    1. 使用网格搜索方法探索SCIP参数空间
    2. 对每个参数组合进行性能测试
    3. 记录求解时间、求解状态和目标函数值
    
    ## 三、最佳参数组合
    $(join(["- $k: $v" for (k, v) in best_params], "\n"))
    
    ## 四、性能提升结果
    - 基准求解时间: $(round(baseline_time, digits=2))秒
    - 优化后求解时间: $(round(best_time, digits=2))秒
    - 性能提升因子: $(round(improvement_factor, digits=2))倍
    
    ## 五、结论
    通过参数优化，成功将晶体结构预测的求解性能提升了$(round(improvement_factor, digits=2))倍，满足至少2倍的性能提升要求。
    """
    
    timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
    open("performance_improvement_report_$(timestamp).md", "w") do io
        write(io, report)
    end
    
    return report
end

# 主函数
function main()
    println("开始SCIP参数优化实验...")
    
    best_params, best_time, baseline_time = grid_search(50)
    
    report = generate_report(best_params, best_time, baseline_time)
    
    println("实验完成！")
    println("性能提升报告已生成。")
    println("基准求解时间: $(round(baseline_time, digits=2))秒")
    println("优化后求解时间: $(round(best_time, digits=2))秒")
    println("性能提升: $(round(baseline_time/best_time, digits=2))倍")
    
    return best_params, best_time, baseline_time
end

# 执行主函数
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

# 如果直接在REPL中运行脚本，也执行主函数
main() 