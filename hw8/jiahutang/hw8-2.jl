using SpinDynamics, Graphs, CairoMakie # CairoMakie might not be needed if no plotting
using SpinDynamics: SVector # Make sure SVector is accessible
using LinearAlgebra

function find_half_adder_inputs_fixed_outputs()
    @info "Setting up 5-spin system for half-adder with fixed outputs S=0 (sS=+1), C=1 (sC=-1)..."

    num_spins = 5 # 1:A, 2:B, 3:C, 4:S, 5:X (auxiliary)
    topology = SimpleGraph(num_spins)

    # Define edges and their coupling strengths (K_ij for H = sum K_ij s_i s_j + ...)
    # Order of adding edges must match the couplings vector
    # K_p = 3.0
    # K_12 = 1.5 (A-B)
    add_edge!(topology, 1, 2)
    # K_13 = -1.5 (A-C)
    add_edge!(topology, 1, 3)
    # K_15 = -1.5 (A-X)
    add_edge!(topology, 1, 5)
    # K_23 = -1.5 (B-C)
    add_edge!(topology, 2, 3)
    # K_25 = -1.5 (B-X)
    add_edge!(topology, 2, 5)
    # K_45 = -3.0 (S-X)
    add_edge!(topology, 4, 5)

    couplings = [
        1.5,  # K_12 (A-B)
        -1.5, # K_13 (A-C)
        -1.5, # K_15 (A-X)
        -1.5, # K_23 (B-C)
        -1.5, # K_25 (B-X)
        -3.0  # K_45 (S-X)
    ]

    # Define external magnetic fields (B_i for H = ... + sum B_i s_i)
    M_penalty = 100.0 # Large field to fix s_C and s_S

    external_fields_z = [
        1.5,        # B_1 (A)
        1.5,        # B_2 (B)
        -101.5,     # B_3 (C) = -1.5 (logic) - M_penalty (to fix s_C = -1)
        100.0,      # B_4 (S) =  0.0 (logic) + M_penalty (to fix s_S = +1)
        -1.5        # B_5 (X)
    ]
    external_fields = [SVector(0.0, 0.0, Bz) for Bz in external_fields_z]

    sys = ClassicalSpinSystem(
        topology,
        couplings,
        external_fields
    )
    @info "Initialized spin system with $(nv(topology)) spins and $(ne(topology)) edges."
    @info "Edges: $(collect(edges(topology)))"
    @info "Couplings: $couplings"
    @info "External Fields (z-comp): $external_fields_z"


    # Initialize spins
    # A, B, X can be somewhat random, C and S should be initialized to their target values.
    s_A_init_vec = SVector(0.0, 0.0, rand([-1.0, 1.0])) # Random A
    s_B_init_vec = SVector(0.0, 0.0, rand([-1.0, 1.0])) # Random B
    s_C_init_vec = SVector(0.0, 0.0, -1.0) # Target s_C = -1 (for C=1)
    s_S_init_vec = SVector(0.0, 0.0, 1.0)  # Target s_S = +1 (for S=0)
    s_X_init_vec = SVector(0.0, 0.0, sign(s_A_init_vec[3] * s_B_init_vec[3])) # s_X should be s_A*s_B

    initial_spins = [s_A_init_vec, s_B_init_vec, s_C_init_vec, s_S_init_vec, s_X_init_vec]
    @info "Initial spin states (z-comp): $([s[3] for s in initial_spins])"

    # Simulation parameters
    nsteps = 30000  # Might need more for 5 spins and strong fields
    dt = 0.01       # Time step for LLG dynamics
    alpha = 0.1     # Damping parameter for LLG

    # Use Landau-Lifshitz-Gilbert (LLG) dynamics for classical spins
    # algorithm_choice = LandauLifshitzGilbert(alpha)

    @info "Running simulation for $(nsteps) steps with dt=$(dt), alpha=$(alpha)..."
    # Note: simulate! in SpinDynamics.jl modifies initial_spins in-place
    # and returns it as final_state.
    # We should pass a copy if we want to preserve initial_spins.
    spins_for_simulation = deepcopy(initial_spins)
    final_state_obj, history = simulate!(
        spins_for_simulation, # This will be modified to become the final_state
        sys;
        nsteps=nsteps,
        dt=dt,
        # checkpoint_steps=checkpoint_interval, # Checkpoint functionality might vary
        algorithm=TrotterSuzuki{2}(topology)
    )
    # final_state_spins will be the same as spins_for_simulation after the call
    final_state_spins = spins_for_simulation 
    @info "Simulation complete."

    # Read out the spin configuration
    s_A_vec_final = final_state_spins[1]
    s_B_vec_final = final_state_spins[2]
    s_C_vec_final = final_state_spins[3] # For verification
    s_S_vec_final = final_state_spins[4] # For verification
    s_X_vec_final = final_state_spins[5] # For verification

    # Get the sign of the z-component for Ising spin values
    s_A_final = sign(s_A_vec_final[3])
    s_B_final = sign(s_B_vec_final[3])
    s_C_final = sign(s_C_vec_final[3]) # Should be -1
    s_S_final = sign(s_S_vec_final[3]) # Should be +1
    s_X_final = sign(s_X_vec_final[3]) # Should be s_A_final * s_B_final

    # Convert Ising spins (-1 or +1) to Boolean (0 or 1)
    # Mapping: Boolean 0 <=> Spin +1, Boolean 1 <=> Spin -1
    # Formula: Boolean_val = (1 - Spin_val) / 2
    A_boolean = (1 - s_A_final) / 2
    B_boolean = (1 - s_B_final) / 2
    C_boolean_final = (1 - s_C_final) / 2 # Expected 1
    S_boolean_final = (1 - s_S_final) / 2 # Expected 0

    println("--- Results ---")
    println("Final spin vectors (raw 3D vectors, z-component shown):")
    println("  s_A_vec_z: ", s_A_vec_final[3])
    println("  s_B_vec_z: ", s_B_vec_final[3])
    println("  s_C_vec_z: ", s_C_vec_final[3], " (Target C=1 => s_C=-1)")
    println("  s_S_vec_z: ", s_S_vec_final[3], " (Target S=0 => s_S=+1)")
    println("  s_X_vec_z: ", s_X_vec_final[3])
    println("Final Ising spins (sign of z-components):")
    println("  s_A: ", s_A_final)
    println("  s_B: ", s_B_final)
    println("  s_C: ", s_C_final, " (Target -1)")
    println("  s_S: ", s_S_final, " (Target +1)")
    println("  s_X: ", s_X_final, " (Should be s_A*s_B = ", s_A_final*s_B_final, ")")
    println("Inferred Boolean inputs (A, B):")
    println("  A: ", Int(A_boolean))
    println("  B: ", Int(B_boolean))
    println("Final Boolean outputs (S, C) for verification:")
    println("  S_final: ", Int(S_boolean_final), " (Target 0)")
    println("  C_final: ", Int(C_boolean_final), " (Target 1)")

    println("\n--- Analytical Expectation ---")
    println("For S=0, C=1:")
    println("  Inputs A=1 (s_A=-1), B=1 (s_B=-1)")
    println("  Outputs s_C=-1, s_S=+1")
    println("  Auxiliary s_X = s_A*s_B = (-1)*(-1) = +1")

    # Verify logic
    valid_C_logic = (s_C_final == sign(s_A_final * s_B_final * (if (s_A_final == -1 && s_B_final == -1) then -1 else 1 end))) # Complex due to AND
    # Easier: check if P_spin for AND is minimized for s_A,s_B,s_C
    # bool_A_f = (1-s_A_final)/2; bool_B_f = (1-s_B_final)/2; bool_C_f = (1-s_C_final)/2
    # and_ok = (round(Int, bool_C_f) == round(Int, bool_A_f*bool_B_f))
    # xor_ok = (round(Int, (1-s_S_final)/2) == round(Int, xor(bool_A_f,bool_B_f)))
    # @info "Logic check: AND gate satisfied? $and_ok, XOR gate satisfied? $xor_ok"
end

# Run the simulation
find_half_adder_inputs_fixed_outputs()