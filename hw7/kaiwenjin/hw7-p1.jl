############
# Problem 1
############

using Random, Graphs, ProblemReductions

function fullerene()
    th = (1 + sqrt(5)) / 2
    res = NTuple{3, Float64}[]
    for (x, y, z) in ((0.0, 1.0, 3th), (1.0, 2 + th, 2th), (th, 2.0, 2th + 1.0))
        for (a, b, c) in ((x,y,z), (y,z,x), (z,x,y))
            for loc in ((a,b,c), (a,b,-c), (a,-b,c), (a,-b,-c), (-a,b,c), (-a,b,-c), (-a,-b,c), (-a,-b,-c))
                if loc ∉ res
                    push!(res, loc)
                end
            end
        end
    end
    return res
end

fullerene_graph = UnitDiskGraph(fullerene(), sqrt(5))
function compute_energy(graph::AbstractGraph, spins::Vector{Int})
    energy = 0
    for e in edges(graph)
        i, j = src(e), dst(e)
        energy += spins[i] * spins[j]
    end
    return energy
end

function simulated_annealing(
    graph::AbstractGraph;
    T0::Float64 = 10.0,      # 初始温度
    T_min::Float64 = 1e-5,   # 终止温度
    cooling_rate::Float64 = 0.99,  # 冷却速率
    max_steps::Int = 100_000  # 最大步数
 )
    n = nv(graph)
    spins = rand([-1, 1], n)  # 随机初始化自旋
    current_energy = compute_energy(graph, spins)
    best_spins = copy(spins)
    best_energy = current_energy
    
    T = T0
    for step in 1:max_steps
        # 随机翻转一个自旋
        flip_pos = rand(1:n)
        new_spins = copy(spins)
        new_spins[flip_pos] *= -1
        
        # 计算能量变化
        new_energy = compute_energy(graph, new_spins)
        ΔE = new_energy - current_energy
        
        # Metropolis准则
        if ΔE < 0 || exp(-ΔE / T) > rand()
            spins = new_spins
            current_energy = new_energy
            
            # 更新最优解
            if current_energy < best_energy
                best_spins = copy(spins)
                best_energy = current_energy
            end
        end
        
        # 降温
        T *= cooling_rate
        T <= T_min && break
    end
    
    return best_spins, best_energy
end

ground_state, min_energy = simulated_annealing(fullerene_graph,
    T0 = 5.0,
    cooling_rate = 0.995,
    max_steps = 1_000_000
)

println("the ground state energy is: ", min_energy)
# -66

println("the ground state spin configuration is: ", ground_state)
# [1, -1, -1, 1, -1, 1, 1, -1, -1, 1, -1, 1, -1, -1, -1, 1, 1, 1, -1, -1, -1, 1, -1, 1, -1, 1, -1, 1, -1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, -1, -1, -1, 1, -1, 1, 1, 1, -1, -1, -1, 1, 1, 1, -1, 1, -1, 1, -1, 1, -1]

