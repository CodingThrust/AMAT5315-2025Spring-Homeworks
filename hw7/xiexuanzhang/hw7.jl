1.
using Graphs
using Random
using LinearAlgebra

# 定义伊辛模型哈密顿量
function ising_hamiltonian(graph, spins)
    E = 0
    for e in edges(graph)
        i, j = src(e), dst(e)
        E += spins[i] * spins[j]
    end
    return E
end

# 模拟退火算法
function simulated_annealing(graph, T_max = 100.0, T_min = 1e-3, α = 0.99, num_steps = 1000)
    num_spins = nv(graph)
    spins = [rand([-1, 1]) for _ in 1:num_spins]
    current_E = ising_hamiltonian(graph, spins)
    best_E = current_E
    best_spins = deepcopy(spins)
    T = T_max
    while T > T_min
        for _ in 1:num_steps
            # 随机选择一个自旋翻转
            idx = rand(1:num_spins)
            proposed_spins = deepcopy(spins)
            proposed_spins[idx] *= -1
            proposed_E = ising_hamiltonian(graph, proposed_spins)
            ΔE = proposed_E - current_E
            if ΔE < 0 || exp(-ΔE / T) > rand()
                spins = proposed_spins
                current_E = proposed_E
                if current_E < best_E
                    best_E = current_E
                    best_spins = deepcopy(spins)
                end
            end
        end
        T *= α
    end
    return best_E, best_spins
end

# 构建富勒烯图
function fullerene()
    th = (1 + sqrt(5)) / 2
    res = NTuple{3, Float64}[]
    for (x, y, z) in ((0.0, 1.0, 3th), (1.0, 2 + th, 2th), (th, 2.0, 2th + 1.0))
        for (a, b, c) in ((x, y, z), (y, z, x), (z, x, y))
            for loc in ((a, b, c), (a, b, -c), (a, -b, c), (a, -b, -c), (-a, b, c), (-a, b, -c), (-a, -b, c), (-a, -b, -c))
                if loc ∉ res
                    push!(res, loc)
                end
            end
        end
    end
    return res
end

fullerene_graph = UnitDiskGraph(fullerene(), sqrt(5))

# 运行模拟退火算法
ground_state_energy, _ = simulated_annealing(fullerene_graph)
println("Ground state energy: ", ground_state_energy)

2.
ENV["GKSwstype"] = "100"
using Graphs, LinearAlgebra, SparseArrays, Arpack
using Makie, CairoMakie  # 使用 Makie 绘图

# ---------------------
# 图拓扑结构定义
# ---------------------
function triangle_graph(n::Int)
    g = Graph(n)
    for i in 1:n-2
        add_edge!(g, i, i+1)
        add_edge!(g, i, i+2)
    end
    return g
end

function square_graph(n::Int)
    g = Graph(n)
    for i in 1:n-1
        add_edge!(g, i, i+1)
    end
    for i in 1:2:n-2
        add_edge!(g, i, i+2)
    end
    return g
end

function diamond_graph(n::Int)
    g = Graph(n)
    for i in 1:n-1
        add_edge!(g, i, i+1)
    end
    for i in 1:n-2
        add_edge!(g, i, i+2)
    end
    return g
end

# ---------------------
# 伊辛模型能量函数
# ---------------------
function energy(g::Graph, spin::Vector{Int})
    E = 0
    for e in edges(g)
        E += spin[src(e)] * spin[dst(e)]
    end
    return E
end

# ---------------------
# 稀疏转移矩阵构造
# ---------------------
function transition_matrix_sparse(g::Graph, β::Float64)
    N = nv(g)
    total_states = 2^N
    I = Int[]; J = Int[]; V = Float64[]

    readbit(cfg, i::Int) = (cfg >> (i - 1)) & 1
    int2cfg(cfg::Int) = [2*readbit(cfg, i) - 1 for i in 1:N]

    for j_col in 1:total_states
        state_j = int2cfg(j_col - 1)
        sum_prob = 0.0

        for k in 1:N
            i_row = (j_col - 1) ⊻ (1 << (k - 1)) + 1
            state_i = int2cfg(i_row - 1)
            ΔE = energy(g, state_i) - energy(g, state_j)
            prob = min(1.0, exp(-β * ΔE)) / N

            push!(I, i_row)
            push!(J, j_col)
            push!(V, prob)
            sum_prob += prob
        end

        push!(I, j_col)
        push!(J, j_col)
        push!(V, 1.0 - sum_prob)
    end

    return sparse(I, J, V, total_states, total_states)
end

# ---------------------
# 谱隙计算
# ---------------------
function spectral_gap(P::SparseMatrixCSC)
    λ, _, _ = eigs(P, nev=3, which=:LR)
    sorted = sort(λ; by=real, rev=true)
    return 1.0 - real(sorted[2])
end

# ---------------------
# 批量计算谱隙 vs β（温度）
# ---------------------
function run_vs_temperature(g::Graph, β_list::Vector{Float64})
    gaps = Float64[]
    for β in β_list
        P = transition_matrix_sparse(g, β)
        gap = spectral_gap(P)
        println("β = $(round(β, digits=2)) → gap = $(round(gap, digits=6))")
        push!(gaps, gap)
    end
    return gaps
end

# ---------------------
# 批量计算谱隙 vs 系统尺寸
# ---------------------
function run_vs_size(graph_constructor, N_list, β)
    gaps = Float64[]
    for N in N_list
        g = graph_constructor(N)
        P = transition_matrix_sparse(g, β)
        gap = spectral_gap(P)
        println("N = $N → gap = $(round(gap, digits=6))")
        push!(gaps, gap)
    end
    return gaps
end

# ---------------------
# 绘图与保存（Makie 风格，直接保存到当前目录）
# ---------------------
function plot_and_save(x, y_list, labels, xlabel, ylabel, title, filename)
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel = xlabel, ylabel = ylabel, title = title)
    
    for (y, label) in zip(y_list, labels)
        scatter!(ax, x, y, markersize=6, label=label)
        lines!(ax, x, y, label=label)
    end
    
    axislegend(ax, position=:lt)
    CairoMakie.save(filename, fig)  # 直接保存到当前目录
    display(fig)
end

# ---------------------
# 主程序
# ---------------------
# ---------------------
# 主程序
# ---------------------
function main()
    println("伊辛模型谱隙分析程序（无results文件夹）")
    println("="^40)
    
    # ===== 任务1：谱隙 vs 温度（β） =====
    println("计算谱隙与温度的关系...")
    N = 8                                  
    β_list = 0.1:0.2:2.0                    # 这是 StepRangeLen 类型
    g_tri = triangle_graph(N)
    g_sq = square_graph(N)
    g_dia = diamond_graph(N)
    
    # 用 collect() 转换为 Vector{Float64}
    gaps_tri = run_vs_temperature(g_tri, collect(β_list))
    gaps_sq = run_vs_temperature(g_sq, collect(β_list))
    gaps_dia = run_vs_temperature(g_dia, collect(β_list))
    
    # 保存为 fig1.png（当前目录）
    plot_and_save(
        β_list,
        [gaps_tri, gaps_sq, gaps_dia],
        ["Triangle", "Square", "Diamond"],
        "β (1/Temperature)",
        "Spectral Gap",
        "Spectral Gap vs Temperature",
        "fig1.png"  # 直接保存到当前目录
    )
    println("图1已保存至: fig1.png")
    
    # ===== 任务2：谱隙 vs 系统尺寸 =====
    println("\n计算谱隙与系统尺寸的关系...")
    β = 1.0                                 
    N_list = 4:2:10                         # 这是 Vector{Int}，无需转换
    
    gaps_tri_size = run_vs_size(triangle_graph, N_list, β)
    gaps_sq_size = run_vs_size(square_graph, N_list, β)
    gaps_dia_size = run_vs_size(diamond_graph, N_list, β)
    
    # 保存为 fig2.png（当前目录）
    plot_and_save(
        N_list,
        [gaps_tri_size, gaps_sq_size, gaps_dia_size],
        ["Triangle", "Square", "Diamond"],
        "System Size (N)",
        "Spectral Gap",
        "Spectral Gap vs System Size (β=1.0)",
        "fig2.png"  # 直接保存到当前目录
    )
    println("图2已保存至: fig2.png")
end

main()