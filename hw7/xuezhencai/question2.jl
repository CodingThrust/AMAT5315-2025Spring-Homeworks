ENV["GKSwstype"] = "100"
using Graphs, LinearAlgebra, SparseArrays, Arpack, Plots

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
# Ising 模型能量函数
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
# 批量谱隙计算 vs β
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
# 主程序执行
# ---------------------
β_list = 0.1:0.2:2.0

# 构造图（节点数要一致以便比较）
N = 8
g_tri = triangle_graph(N)
g_sq  = square_graph(N)
g_dia = diamond_graph(N)

# 分别计算谱隙
gaps_tri = run_vs_temperature(g_tri, collect(β_list))
gaps_sq  = run_vs_temperature(g_sq,  collect(β_list))
gaps_dia = run_vs_temperature(g_dia, collect(β_list))

# 绘图
plot(β_list, gaps_tri, label="Triangle", lw=2, marker=:circle)
plot!(β_list, gaps_sq,  label="Square",   lw=2, marker=:diamond)
plot!(β_list, gaps_dia, label="Diamond",  lw=2, marker=:utriangle)
xlabel!("β")
ylabel!("Spectral Gap")
title!("Gap vs β")
savefig("gap_vs_beta_all.pdf")
