### 1. (Ground state energy)

using Graphs, Random, LinearAlgebra,ProblemReductions
# Construct the Fullerene graph 
function fullerene()
    th = (1 + sqrt(5)) / 2
    res = NTuple{3,Float64}[]
    for (x, y, z) in ((0.0, 1.0, 3*th), (1.0, 2 + th, 2*th), (th, 2.0, 2*th + 1.0))
        for (a, b, c) in ((x, y, z), (y, z, x), (z, x, y))
            for loc in ((a, b, c), (a, b, -c), (a, -b, c), (a, -b, -c),
                        (-a, b, c), (-a, b, -c), (-a, -b, c), (-a, -b, -c))
                if loc ∉ res
                    push!(res, loc)
                end
            end
        end
    end
    return res
end

# Generate the graph
fullerene_pos = fullerene()
fullerene_graph = UnitDiskGraph(fullerene_pos, sqrt(5))

# Simulated Annealing
function ising_energy(graph, spins)
    energy = 0
    for e in edges(graph)
        energy += spins[src(e)] * spins[dst(e)]
    end
    return energy
end

function simulated_annealing(graph; steps=10^6, T0=10.0, Tf=0.01)
    n = nv(graph)
    spins = rand([-1, 1], n)
    energy = ising_energy(graph, spins)
    best_energy = energy
    best_spins = copy(spins)

    for step in 1:steps
        T = T0 * (Tf / T0)^(step / steps)  # Cooling schedule
        site = rand(1:n)
        new_spins = copy(spins)
        new_spins[site] *= -1
        new_energy = ising_energy(graph, new_spins)

        if new_energy < energy || exp(-(new_energy - energy) / T) > rand()
            spins = new_spins
            energy = new_energy
            if energy < best_energy
                best_energy = energy
                best_spins = copy(spins)
            end
        end
    end
    return best_energy, best_spins
end

# Run and print result
ground_energy, _ = simulated_annealing(fullerene_graph)
println("Ground state energy estimate: ", ground_energy)
# => -66



### 2. (Spectral gap)
ENV["GKSwstype"] = "100"
using Graphs, LinearAlgebra, SparseArrays, Arpack
using Makie, CairoMakie 


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


function energy(g::Graph, spin::Vector{Int})
    E = 0
    for e in edges(g)
        E += spin[src(e)] * spin[dst(e)]
    end
    return E
end


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


function spectral_gap(P::SparseMatrixCSC)
    λ, _, _ = eigs(P, nev=3, which=:LR)
    sorted = sort(λ; by=real, rev=true)
    return 1.0 - real(sorted[2])
end


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


function plot_and_save(x, y_list, labels, xlabel, ylabel, title, filename)
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel = xlabel, ylabel = ylabel, title = title)

    for (y, label) in zip(y_list, labels)
        scatter!(ax, x, y, markersize=6, label=label)
        lines!(ax, x, y, label=label)
    end

    axislegend(ax, position=:lt)
    CairoMakie.save(filename, fig) 
    display(fig)
end


function main()
   
    N = 18                                  
    β_list = 0.1:0.2:2.0                   
    g_tri = triangle_graph(N)
    g_sq = square_graph(N)
    g_dia = diamond_graph(N)

  
    gaps_tri = run_vs_temperature(g_tri, collect(β_list))
    gaps_sq = run_vs_temperature(g_sq, collect(β_list))
    gaps_dia = run_vs_temperature(g_dia, collect(β_list))

    
    plot_and_save(
        β_list,
        [gaps_tri, gaps_sq, gaps_dia],
        ["Triangle", "Square", "Diamond"],
        "β (1/Temperature)",
        "Spectral Gap",
        "Spectral Gap vs Temperature",
        "fig1.png"  
    )
   

    #size
    β = 1.0                                 
    N_list = 4:2:18                      

    gaps_tri_size = run_vs_size(triangle_graph, N_list, β)
    gaps_sq_size = run_vs_size(square_graph, N_list, β)
    gaps_dia_size = run_vs_size(diamond_graph, N_list, β)

    plot_and_save(
        N_list,
        [gaps_tri_size, gaps_sq_size, gaps_dia_size],
        ["Triangle", "Square", "Diamond"],
        "System Size (N)",
        "Spectral Gap",
        "Spectral Gap vs System Size (β=1.0)",
        "fig2.png"  
    )
end

main()