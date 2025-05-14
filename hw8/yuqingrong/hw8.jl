using Random

# Define the half adder energy function with spin variables
function half_adder_energy(σA, σB, σS, σC)
    # XOR: S = A ⊕ B
    h_xor = 0.25 * (1 - σA * σB * σS)

    # AND: C = A ∧ B
    h_and = 0.25 * (3 + σA + σB - σA * σB - 4 * σC + 2 * σA * σC + 2 * σB * σC)

    return h_xor + h_and
end

# Convert spin (±1) to boolean (0/1)
function spin_to_bool(σ)
    return σ == 1 ? 1 : 0
end

# Convert boolean (0/1) to spin (±1)
function bool_to_spin(b)
    return b == 1 ? 1 : -1
end

# Spin dynamics simulation with fixed outputs
function spin_dynamics_simulation(fixed_σS, fixed_σC, max_steps=1000)
    # Initialize random spin configuration for inputs
    σA = rand([-1, 1])
    σB = rand([-1, 1])
    σS = fixed_σS  # Fixed output S
    σC = fixed_σC  # Fixed output C
    
    # Current energy
    current_energy = half_adder_energy(σA, σB, σS, σC)
    
    # Temperature parameter (for simulated annealing)
    T = 1.0
    cooling_rate = 0.95
    
    for step in 1:max_steps
        # Propose a flip for either σA or σB
        if rand() < 0.5
            proposed_σA = -σA
            proposed_σB = σB
        else
            proposed_σA = σA
            proposed_σB = -σB
        end
        
        # Calculate energy with proposed flip
        proposed_energy = half_adder_energy(proposed_σA, proposed_σB, σS, σC)
        
        # Energy difference
        ΔE = proposed_energy - current_energy
        
        # Accept or reject the flip based on energy difference
        if ΔE <= 0 || rand() < exp(-ΔE / T)
            σA = proposed_σA
            σB = proposed_σB
            current_energy = proposed_energy
        end
        
        # Cool down the temperature
        if step % 100 == 0
            T *= cooling_rate
        end
        
        # If we found a ground state (energy = 0), we can stop
        if isapprox(current_energy, 0.0, atol=1e-10)
            break
        end
    end
    
    return σA, σB, σS, σC, current_energy
end

# Main function to solve the half adder with fixed outputs
function solve_half_adder_with_fixed_outputs()
    # Fixed outputs: S=0, C=1
    fixed_σS = bool_to_spin(0)  # S=0 -> σS=-1
    fixed_σC = bool_to_spin(1)  # C=1 -> σC=1
    
    # Run multiple simulations to ensure we find the ground state
    best_energy = Inf
    best_config = nothing
    
    for i in 1:100
        σA, σB, σS, σC, energy = spin_dynamics_simulation(fixed_σS, fixed_σC)
        if energy < best_energy
            best_energy = energy
            best_config = (σA, σB, σS, σC)
        end
    end
    
    σA, σB, σS, σC = best_config
    
    # Convert spins to boolean values
    A = spin_to_bool(σA)
    B = spin_to_bool(σB)
    S = spin_to_bool(σS)
    C = spin_to_bool(σC)
    
    println("Ground state found with energy: $best_energy")
    println("Input configuration:")
    println("A = $A (σA = $σA)")
    println("B = $B (σB = $σB)")
    println("Output configuration (fixed):")
    println("S = $S (σS = $σS)")
    println("C = $C (σC = $σC)")
    
    # Verify the solution
    println("\nVerification:")
    println("XOR: $A ⊕ $B = $S")
    println("AND: $A ∧ $B = $C")
    
    return A, B, S, C
end

# Run the solver
solve_half_adder_with_fixed_outputs()
# => (1, 0, 0, 1)