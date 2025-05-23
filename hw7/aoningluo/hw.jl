1.
using Graphs, ProblemReductions
function fullerene()  # construct the fullerene graph in 3D space
        th = (1+sqrt(5))/2
        res = NTuple{3,Float64}[]
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
fullerene_graph = UnitDiskGraph(fullerene(), sqrt(5)); # construct the unit disk graph

params = (
    initial_temp = 100.0, 
    cooling_rate = 0.995, 
    steps = 50000,         
    trials = 10             
)

function calculate_energy(spins, graph)
    energy = 0.0
    for e in edges(graph)
        energy += spins[src(e)] * spins[dst(e)]
    end
    return energy
end

function simulated_annealing(graph, params)
    best_energy = Inf
    best_spins = []
    
    for _ in 1:params.trials
        spins = rand([-1, 1], nv(graph))
        current_energy = calculate_energy(spins, graph)
        temp = params.initial_temp
        
        for step in 1:params.steps
            idx = rand(1:length(spins))
            new_spins = copy(spins)
            new_spins[idx] *= -1
            new_energy = calculate_energy(new_spins, graph)
            
            ΔE = new_energy - current_energy
            if ΔE < 0 || rand() < exp(-ΔE/temp)
                spins = new_spins
                current_energy = new_energy
            end
            
            if current_energy < best_energy
                best_energy = current_energy
                best_spins = copy(spins)
            end
            
            temp *= params.cooling_rate
        end
    end
    return best_energy, best_spins
end

ground_energy, optimal_spins = simulated_annealing(fullerene_graph, params)
println("基态能量预测值: ", ground_energy)

2.
using LinearAlgebra
using SparseArrays
using Arpack: eigs
using Plots


function spectral_gap(H)
    eigs_result = eigs(H, nev=2, which=:SR)
    return abs(eigs_result[1][1] - eigs_result[1][2])
end

function generate_topology(N, topology::String)
    if topology == "Triangles"
        A = spzeros(N,N)
        for i=1:N-2
            A[i,i+1] = A[i+1,i] = 1
            A[i,i+2] = A[i+2,i] = 1
            A[i+1,i+2] = A[i+2,i+1] = 1
        end
        return A
    elseif topology == "Squares"
        A = spzeros(N,N)
        for i=1:4:N-3
            A[i,i+1] = A[i+1,i] = 1
            A[i+1,i+2] = A[i+2,i+1] = 1
            A[i+2,i+3] = A[i+3,i+2] = 1
            A[i+3,i] = A[i,i+3] = 1
        end
        return A
    elseif topology == "Diamonds"
        A = spzeros(N,N)
        for i=1:5:N-4
            A[i,i+1] = A[i+1,i] = 1
            A[i,i+2] = A[i+2,i] = 1
            A[i+1,i+3] = A[i+3,i+1] = 1
            A[i+2,i+3] = A[i+3,i+2] = 1
        end
        return A
    else
        error("Unknown topology: $topology")
    end
end

function ising_hamiltonian(N, J, h, topology)
    A = generate_topology(N, topology)
    H = spzeros(2^N, 2^N) 
    for i=1:N
        for j=i+1:N
            if A[i,j] != 0
            
            end
        end
    end
    
    return H
end

function task_i()
    T_values = 0.1:0.1:2.0
    N = 8 
    J = 1.0 
    topologies = ["Triangles", "Squares", "Diamonds"]
    
    plt = plot(xlabel="Temperature T", ylabel="Spectral Gap", 
              title="Spectral Gap vs Temperature (N=$N)", legend=:topright)
    
    for topology in topologies
        gap_values = Float64[]
        for T in T_values
            h = 1/T 
            H = ising_hamiltonian(N, J, h, topology)
            gap = spectral_gap(H)
            push!(gap_values, gap)
        end
        plot!(plt, T_values, gap_values, label=topology)
    end
    
    savefig("spectral_gap_vs_temperature.png")
    return plt
end

function task_ii()
    N_values = 4:2:12 
    T = 0.5  
    J = 1.0  
    h = 1/T  
    topologies = ["Triangles", "Squares", "Diamonds"]
    
    plt = plot(xlabel="System Size N", ylabel="Spectral Gap", 
              title="Spectral Gap vs System Size (T=$T)", legend=:topright)
    
    for topology in topologies
        gap_values = Float64[]
        for N in N_values
            H = ising_hamiltonian(N, J, h, topology)
            gap = spectral_gap(H)
            push!(gap_values, gap)
        end
        plot!(plt, N_values, gap_values, label=topology, marker=:circle)
    end
    
    savefig("spectral_gap_vs_system_size.png")
    return plt
end

task_i()
task_ii()
