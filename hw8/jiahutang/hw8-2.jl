Pkg.activate(".")
# using SpinDynamics, Graphs
# using SpinDynamics: SVector # Assuming SVector is exported or aliased by SpinDynamics
# # If SVector is not found in SpinDynamics, it's likely from StaticArrays.jl
# # In that case, add `using StaticArrays` and use `StaticArrays.SVector`.

function find_half_adder_inputs()
    @info "Setting up 4-spin system for half-adder with fixed outputs S=0, C=1..."

    num_spins = 4 # A, B, C, S
    topology = SimpleGraph(num_spins)

    # Define edges and their coupling strengths (J_ij)
    # Spin indices: 1:A, 2:B, 3:C, 4:S
    # J_AC = 2.0
    add_edge!(topology, 1, 3)
    # J_BC = 2.0
    add_edge!(topology, 2, 3)
    # J_AS = 1.0
    add_edge!(topology, 1, 4)
    # J_BS = 1.0
    add_edge!(topology, 2, 4)
    # Other couplings (J_AB, J_CS) are 0, so no edges needed for them.

    # Couplings vector corresponds to the order edges were added:
    # Order: (1,3), (2,3), (1,4), (2,4)
    couplings = [2.0, 2.0, 1.0, 1.0] # These are K_ij for H = - sum K_ij S_i.S_j - sum B_i.S_i

    # Define external magnetic fields (h_i)
    # h_A = 2.0, h_B = 2.0, h_C = -2.0, h_S = 1.0
    M_penalty = 100.0 # Large field to fix s_C and s_S

    external_fields = [
        SVector(0.0, 0.0, 2.0),                         # Field on A (h_A)
        SVector(0.0, 0.0, 2.0),                         # Field on B (h_B)
        SVector(0.0, 0.0, -2.0 + M_penalty),           # Field on C (h_C, fixed to +1)
        SVector(0.0, 0.0, 1.0 - M_penalty)            # Field on S (h_S, fixed to -1)
    ]

    sys = ClassicalSpinSystem(
        topology,
        couplings,
        external_fields
    )
    @info "Initialized spin system with $(nv(topology)) spins and $(ne(topology)) edges."

    # Initialize spins
    # A and B are random, C is spin up (+1), S is spin down (-1)
    s_A_init_vec = normalize(randn(SVector{3,Float64}))
    s_B_init_vec = normalize(randn(SVector{3,Float64}))
    s_C_init_vec = SVector(0.0, 0.0, 1.0)  # Target s_C = +1
    s_S_init_vec = SVector(0.0, 0.0, -1.0) # Target s_S = -1
    initial_spins = [s_A_init_vec, s_B_init_vec, s_C_init_vec, s_S_init_vec]
    @info "Initialized spin states."

    # Simulation parameters
    nsteps = 2000  # Increased steps for potentially complex dynamics / strong fields
    dt = 0.01
    checkpoint_interval = 200
    
    # Use algorithm from the user's provided Example 1 structure
    # This was TrotterSuzuki{2}(topology). If this is not compatible with
    # ClassicalSpinSystem in the user's version of SpinDynamics.jl,
    # an alternative like LandauLifshitzGilbert(0.1) should be used.
    # Based on SpinDynamics.jl source, LLG is more appropriate for ClassicalSpinSystem.
    # However, to adhere to the example, we try TrotterSuzuki first.
    # Note: The example code for `simulate_afm_grid` uses `TrotterSuzuki{2}(topology)`.
    # We assume this is valid in the context of the user's environment.
    algorithm_choice = TrotterSuzuki{2}(topology)
    # Fallback if TrotterSuzuki is not compatible:
    # algorithm_choice = LandauLifshitzGilbert(0.1) # alpha is damping parameter

    @info "Running simulation for $(nsteps) steps with dt=$(dt)..."
    final_state, history = simulate!(
        initial_spins,
        sys;
        nsteps=nsteps,
        dt=dt,
        checkpoint_steps=checkpoint_interval,
        algorithm=algorithm_choice
    )
    @info "Simulation complete."

    # Read out the input spin configuration (A and B)
    # The final_state.spins contains 3D spin vectors. We take the z-component.
    s_A_vector = final_state.spins[1]
    s_B_vector = final_state.spins[2]
    s_C_vector = final_state.spins[3] # For verification
    s_S_vector = final_state.spins[4] # For verification

    # Get the sign of the z-component for Ising spin values
    s_A_final = sign(s_A_vector[3])
    s_B_final = sign(s_B_vector[3])
    s_C_final = sign(s_C_vector[3]) # Should be +1
    s_S_final = sign(s_S_vector[3]) # Should be -1

    # Convert Ising spins (-1 or +1) to Boolean (0 or 1)
    A_boolean = (s_A_final + 1) / 2
    B_boolean = (s_B_final + 1) / 2

    println("--- Results ---")
    println("Final spin vectors (raw 3D vectors):")
    println("  s_A_vec: ", s_A_vector)
    println("  s_B_vec: ", s_B_vector)
    println("  s_C_vec: ", s_C_vector, " (Fixed output C=1)")
    println("  s_S_vec: ", s_S_vector, " (Fixed output S=0)")
    println("Final Ising spins (z-components, sign):")
    println("  s_A: ", s_A_final)
    println("  s_B: ", s_B_final)
    println("  s_C: ", s_C_final)
    println("  s_S: ", s_S_final)
    println("Inferred Boolean inputs (A, B):")
    println("  A: ", Int(A_boolean))
    println("  B: ", Int(B_boolean))
    
    # Analytically, for S=0 (sS=-1) and C=1 (sC=+1), the inputs must be A=1, B=1.
    # (sA=+1, sB=+1)
    # Half-adder logic: S = A XOR B, C = A AND B
    # If A=1, B=1: S = 1 XOR 1 = 0 (matches sS=-1)
    #                C = 1 AND 1 = 1 (matches sC=+1)
    # The simulation should find A=1, B=1.
end

# Run the simulation
find_half_adder_inputs()