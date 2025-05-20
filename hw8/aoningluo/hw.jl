1.
using LinearAlgebra
using Plots

function half_adder_hamiltonian(σ)
    σ_A, σ_B, σ_S, σ_C = σ
    
    E_XOR = (1/4) * (2 - 2*σ_A*σ_B - σ_S)^2
    
    E_AND = (1/4) * (1 + σ_A + σ_B + σ_A*σ_B - σ_C)^2
    
    return E_XOR + E_AND
end

function find_ground_state()
    min_energy = Inf
    ground_state = nothing
    
    for σ_A in (-1, 1), σ_B in (-1, 1), σ_S in (-1, 1), σ_C in (-1, 1)
        σ = [σ_A, σ_B, σ_S, σ_C]
        energy = half_adder_hamiltonian(σ)
        
        if energy < min_energy
            min_energy = energy
            ground_state = σ
        end
    end
    
    return ground_state, min_energy
end

function plot_energy_landscape()
    labels = ["00", "01", "10", "11"]
    energies = Float64[]
    
    for (a, b) in [(0,0), (0,1), (1,0), (1,1)]
        σ_A = 2a - 1
        σ_B = 2b - 1
        
        correct_S = a ⊻ b
        correct_C = a & b
        σ_S = 2correct_S - 1
        σ_C = 2correct_C - 1
        
        push!(energies, half_adder_hamiltonian([σ_A, σ_B, σ_S, σ_C]))
    end
    
    plt = bar(labels, energies, 
             xlabel="Input (A,B)", ylabel="Energy", 
             title="Energy Landscape of Half-Adder Spin Glass",
             legend=false, color=:blue)
    
    savefig("half_adder_energy_landscape.png")
    display(plt)
end

function main()
    ground_state, min_energy = find_ground_state()
    
    println("Ground state found:")
    println("σ_A = ", ground_state[1], " (A = ", (ground_state[1]+1)/2, ")")
    println("σ_B = ", ground_state[2], " (B = ", (ground_state[2]+1)/2, ")")
    println("σ_S = ", ground_state[3], " (S = ", (ground_state[3]+1)/2, ")")
    println("σ_C = ", ground_state[4], " (C = ", (ground_state[4]+1)/2, ")")
    println("Minimum energy = ", min_energy)

    plot_energy_landscape()
end

main()

2.
using Random
using Statistics
using Plots

function system_energy(σ_A, σ_B)
    A = (σ_A + 1) ÷ 2
    B = (σ_B + 1) ÷ 2
    S = 0 
    C = 1

    E_S = (A ⊻ B - S)^2 
    E_C = (A & B - C)^2
    
    return E_S + E_C
end

function simulated_annealing(;T_start=10.0, T_end=0.01, steps=1000)

    σ_A = rand([-1, 1])
    σ_B = rand([-1, 1])

    min_energy = system_energy(σ_A, σ_B)
    best_A, best_B = σ_A, σ_B
    
    cooling_rate = (T_end/T_start)^(1/steps)
    
    for step in 1:steps
        T = T_start * cooling_rate^step

        flip_idx = rand(1:2)
        new_A = flip_idx == 1 ? -σ_A : σ_A
        new_B = flip_idx == 2 ? -σ_B : σ_B
        
        current_energy = system_energy(σ_A, σ_B)
        new_energy = system_energy(new_A, new_B)
        ΔE = new_energy - current_energy
        
        if ΔE < 0 || rand() < exp(-ΔE/T)
            σ_A, σ_B = new_A, new_B
            if new_energy < min_energy
                min_energy = new_energy
                best_A, best_B = new_A, new_B
            end
        end
    end
    
    return best_A, best_B, min_energy
end

function plot_energy()
    A_values = -1:2:1
    B_values = -1:2:1
    E = [system_energy(a,b) for a in A_values, b in B_values]
    
    heatmap(A_values, B_values, E',
            xlabel="σ_A", ylabel="σ_B",
            title="Energy Landscape (S=0, C=1)",
            color=:thermal, clims=(0,2))
    
    scatter!([(1,1)], label="Ground State", color=:green, marker=:star, markersize=10)
    savefig("spin_glass_energy.png")
end

function main()
    σ_A, σ_B, energy = simulated_annealing(T_start=5.0, steps=5000)
    
    println("Ground state found:")
    println("σ_A = ", σ_A, " → A = ", (σ_A+1)÷2)
    println("σ_B = ", σ_B, " → B = ", (σ_B+1)÷2)
    println("System energy = ", energy)

    A = (σ_A + 1) ÷ 2
    B = (σ_B + 1) ÷ 2
    println("\nConstraint verification:")
    println("A ⊕ B = ", A ⊻ B, " (should be 0)")
    println("A ∧ B = ", A & B, " (should be 1)")
    
    plot_energy()
end

main()