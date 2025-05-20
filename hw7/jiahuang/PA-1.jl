# Required Packages (ensure these are loaded)
using GenericTensorNetworks, GenericTensorNetworks.Graphs
using Test
using Random
using Printf
using Graphs
using LinearAlgebra # Might be needed by dependencies
using Base.Threads # Import Threads module
using DelimitedFiles # For writing config to file easily
using StatsBase # Added for weighted sampling in resampling

# --- Function Definitions ---
# (strong_product, strong_power, spin_glass_c, get_edge_weights_dict,
#  calculate_energy_manual, calculate_delta_E_01 remain the same)
# --- Assume these functions are defined as in the original code ---

println("Number of threads: ", Threads.nthreads())

# Defines the strong product of two graphs.
function strong_product(g1::SimpleGraph, g2::SimpleGraph)
    vs = [(v1, v2) for v1 in vertices(g1), v2 in vertices(g2)]
    vs_flat = vec(vs)
    vertex_map = Dict(v => i for (i, v) in enumerate(vs_flat))
    inv_vertex_map = Dict(i => v for (i, v) in enumerate(vs_flat))

    graph = SimpleGraph(length(vs_flat))

    for i in 1:length(vs_flat), j in (i+1):length(vs_flat)
        vi = inv_vertex_map[i]
        vj = inv_vertex_map[j]

        is_neighbor = false
        if vi[1] == vj[1] && has_edge(g2, vi[2], vj[2])
            is_neighbor = true
        elseif vi[2] == vj[2] && has_edge(g1, vi[1], vj[1])
            is_neighbor = true
        elseif has_edge(g1, vi[1], vj[1]) && has_edge(g2, vi[2], vj[2])
            is_neighbor = true
        end

        if is_neighbor
            add_edge!(graph, i, j)
        end
    end
    return graph
end

strong_power(g::SimpleGraph, k::Int) = k == 1 ? g : strong_product(g, strong_power(g, k - 1))

function spin_glass_c(n::Int, k::Int)
    g1 = Graphs.cycle_graph(n)
    g = strong_power(g1, k)
    # Use Float64 for consistency with energy calculations
    coupling = ones(Float64, ne(g))
    bias = Float64.(1 .- degree(g))
    @assert length(bias) == nv(g) "Bias vector length ($(length(bias))) mismatch with Nv ($(nv(g)))"
    return SpinGlass(g, coupling, bias)
end

function get_edge_weights_dict(sg::SpinGlass)
    edge_weights = Dict{Edge, Float64}()
    g = sg.graph
    if length(sg.J) != ne(g)
        error("Mismatch between number of edges ($(ne(g))) and number of couplings ($(length(sg.J))).")
    end
    # Ensure J is Float64
    J_float = Float64.(sg.J)
    for (edge, weight) in zip(edges(g), J_float)
        u, v = minmax(src(edge), dst(edge))
        edge_weights[Edge(u, v)] = weight
    end
    return edge_weights
end

"""
Manually calculates the energy for a SpinGlass problem with a 0/1 configuration.
Matches the formula H(sigma) = Σ_{<i,j>} J_ij * σ_i * σ_j - Σ_i h_i * σ_i,
where σ_i = 2*x_i - 1 are +/-1 spins derived from the 0/1 config x.
"""
function calculate_energy_manual(sg::SpinGlass, config::Vector{Int})
    N = nv(sg.graph)
    if length(config) != N
        error("Configuration length ($(length(config))) does not match number of vertices ($N).")
    end
    # Convert 0/1 config (x) to +/-1 config (sigma)
    sigma = (2.0 .* config) .- 1.0

    total_energy::Float64 = 0.0
    g = sg.graph
    J = Float64.(sg.J) # Ensure Float64
    h = (sg.h === nothing || isempty(sg.h)) ? nothing : Float64.(sg.h) # Ensure Float64

    # Coupling Term: Σ J_ij * σ_i * σ_j
    num_edges = ne(g)
    if length(J) != num_edges
         error("Mismatch between number of edges ($num_edges) and number of couplings ($(length(J))).")
    end

    edge_idx = 0
    for edge in edges(g)
        edge_idx += 1
        u = src(edge)
        v = dst(edge)
        weight = J[edge_idx]
        # Check bounds just in case graph/config are inconsistent
        if !(1 <= u <= N && 1 <= v <= N)
             error("Invalid edge indices found in graph: ($u, $v) for graph size $N")
        end
        # Use @inbounds carefully if bounds are guaranteed elsewhere
        # total_energy += weight * (@inbounds sigma[u]) * (@inbounds sigma[v])
        total_energy += weight * sigma[u] * sigma[v]
    end

    # Bias Term: - Σ h_i * σ_i
    if h !== nothing
        if length(h) != N
            error("Bias vector length ($(length(h))) does not match number of vertices ($N).")
        end
        for i in 1:N
            # total_energy -= (@inbounds h[i]) * (@inbounds sigma[i])
             total_energy -= h[i] * sigma[i] # Note the minus sign here
        end
    end
    return total_energy
end


"""
Calculates the change in energy (Delta H) when flipping a single spin at `spin_index`
in a 0/1 configuration `config`. Micro-optimized with @inbounds.
"""
@inline function calculate_delta_E_01(sg::SpinGlass, config::Vector{Int}, spin_index::Int, edge_weights::Dict{Edge, Float64})
    g = sg.graph
    h = sg.h # Access struct field directly
    N = nv(g) # Use graph's vertex count

    # --- Bounds check is CRITICAL before using @inbounds ---
    # This check should ideally be done *before* calling this function in the inner loop
    # if !(1 <= spin_index <= N)
    #     throw(BoundsError(config, spin_index)) # Throw error if index invalid
    # end
    # ---

    # Get the current +/-1 spin value for the index being flipped
    @inbounds sigma_k = 2.0 * config[spin_index] - 1.0

    # Calculate the effective field term: [ Σ_{j~k} J_kj * sigma_j - h_k ]
    effective_field::Float64 = 0.0

    # Add bias contribution (-h_k)
    # Check if h is nothing OR empty before accessing
    if h !== nothing && !isempty(h)
        @inbounds effective_field -= h[spin_index]
    end

    # Add coupling contributions (Σ_{j~k} J_kj * sigma_j)
    # Iterating neighbors is generally efficient in Graphs.jl
    # Assuming graph structure ensures neighbors are valid indices
    @inbounds for neighbor in neighbors(g, spin_index)
        # Get the +/-1 spin value for the neighbor
        sigma_j = 2.0 * config[neighbor] - 1.0

        # Find the edge weight J_kj
        u, v = minmax(spin_index, neighbor)
        edge = Edge(u, v)
        # Dictionary lookup is fast. get() handles missing edges gracefully.
        # Using 0.0 as default should be safe if edge_weights is correctly built.
        weight = get(edge_weights, edge, 0.0)

        effective_field += weight * sigma_j
    end

    # Calculate Delta H = -2 * sigma_k * effective_field
    delta_E = -2.0 * sigma_k * effective_field

    return delta_E
end


# --- Population Annealing Solver (Multi-threaded, with saving) ---
function population_annealing_solver(sg::SpinGlass;
                                population_size::Int = 64,
                                beta_init::Float64 = 1.0/20.0, # Starting inverse temperature (high T)
                                beta_final::Float64 = 1.0/0.05, # Final inverse temperature (low T)
                                num_annealing_steps::Int = 1000, # Number of beta steps
                                sweeps_per_step::Int = 100, # Metropolis sweeps per config per beta step
                                verbose::Bool = false,
                                verification_freq::Int = 500, # Verify less often by default
                                save_best_to_file::Bool = false, # Flag to enable saving
                                filename_prefix::String = "pa_best_config" # Prefix for saved file
                               )
    N = nv(sg.graph)
    g = sg.graph

    if N == 0 return Int[] end
    if length(sg.J) != ne(g)
        error("SpinGlass object has inconsistent number of couplings and edges.")
    end

    # Use Float64 edge weights consistent with energy calculation
    # Pre-calculate for faster lookup in the inner loop
    edge_weights = get_edge_weights_dict(sg)

    # --- Setup Annealing Schedule (Geometric) ---
    if beta_init <= 0 || beta_final <= beta_init
        error("Beta schedule requires 0 < beta_init <= beta_final")
    end
    betas = exp.(range(log(beta_init), log(beta_final), length=num_annealing_steps))

    # --- Initialization ---
    configs = [rand([0, 1], N) for _ in 1:population_size]
    energies = zeros(Float64, population_size)

    # Parallel initialization of energies
    Threads.@threads for c = 1:population_size
         try
            # Use calculate_energy_manual as 'energy' expects +/-1 by default? Check GenericTensorNetworks.jl docs
            # Let's assume 'energy' function from GenericTensorNetworks works correctly with the 0/1 config shape
            energies[c] = energy(sg, reshape(configs[c], 1, N)) # Or use calculate_energy_manual(sg, configs[c])
         catch e
              @error "ERROR in thread $(Threads.threadid()) calculating initial energy for config $c" exception=(e, catch_backtrace())
              energies[c] = NaN
         end
    end
    if any(isnan, energies)
        error("Failed to calculate initial energies for some configurations.")
    end

    min_E_init, min_idx_init = findmin(energies)
    best_config_overall = copy(configs[min_idx_init])
    best_energy_overall = min_E_init
    best_lock = ReentrantLock() # Lock for protecting global best updates

    if verbose
        num_threads = Threads.nthreads()
        total_sweeps = num_annealing_steps * sweeps_per_step * population_size * N # Total spin flips roughly
        @printf("Starting PA: N=%d, Population=%d, Threads=%d, β=[%.3f..%.3f], Steps=%d, Sweeps/Step=%d\n",
                N, population_size, num_threads, beta_init, beta_final, num_annealing_steps, sweeps_per_step)
        @printf("Approx total spin flips: %.2e\n", Float64(total_sweeps))
        @printf("Initial best energy: %.4f\n", best_energy_overall)
        flush(stdout)
    end

    # Save initial best if requested
    if save_best_to_file
        try
            fname = @sprintf("%s_E%.4f_beta%.3f_step0.txt", filename_prefix, best_energy_overall, beta_init)
            open(fname, "w") do f
                writedlm(f, reshape(best_config_overall, 1, :), ' ')
            end
            if verbose
                 println("Saved initial best config to $fname")
                 flush(stdout)
            end
        catch e
            @warn "Could not save initial best config to file: $e"
        end
    end


    # --- Population Annealing Main Loop ---
    for step in 1:num_annealing_steps
        beta = betas[step]

        # --- Parallel Metropolis Sweeps for the current beta ---
        Threads.@threads for c in 1:population_size
            current_config = configs[c]
            current_energy = energies[c]
            if isnan(current_energy) continue end # Skip if invalid from previous step

            rng = Random.default_rng() # Use default thread-safe RNG
            if !(1 <= N) continue end # Skip if N is 0 or less

            # --- Perform sweeps_per_step * N Metropolis steps ---
            for sweep_iter in 1:sweeps_per_step
                 energy_before_sweep = current_energy
                 if isnan(energy_before_sweep) break end # Stop if energy became NaN

                 for _ in 1:N # One full sweep over spins
                    spin_to_flip = rand(rng, 1:N)
                    delta_E = calculate_delta_E_01(sg, current_config, spin_to_flip, edge_weights)

                    accept = false
                    if delta_E <= 0.0 || rand(rng) < exp(-beta * delta_E)
                        accept = true
                    end

                    if accept
                        current_energy += delta_E
                        @inbounds current_config[spin_to_flip] = 1 - current_config[spin_to_flip]
                    end
                 end # End of N steps

                 # --- Verification Step (Optional, less frequent) ---
                 perform_verification = (verification_freq > 0 && sweep_iter % verification_freq == 0)
                 local recalculated_energy = NaN
                 if perform_verification
                     try
                         recalculated_energy = energy(sg, reshape(current_config, 1, N))
                         if !isapprox(current_energy, recalculated_energy, atol=1e-6, rtol=1e-6)
                              @warn @sprintf("Step %d (β=%.3f), Config %d (Thr=%d), Sweep %d: Energy mismatch! Tracked E = %.5f -> %.5f (Δ=%.5f), Recalculated E = %.5f. Diff = %.5g",
                                             step, beta, c, Threads.threadid(), energy_before_sweep, current_energy, current_energy-energy_before_sweep, recalculated_energy, current_energy - recalculated_energy)
                              current_energy = recalculated_energy # Resync
                         end
                     catch e
                         @warn "Error during energy verification for config $c, step $step, sweep $sweep_iter: $e"
                         current_energy = NaN # Mark as potentially unreliable
                     end
                 end

            end # End of sweeps_per_step loop

            energies[c] = current_energy # Store updated energy for this config

            # --- Update Global Best (Thread-Safe) ---
            if !isnan(current_energy)
                # Quick check outside lock
                if current_energy < best_energy_overall - 1e-9
                    lock(best_lock)
                    try
                        # Re-check condition after acquiring lock
                        if current_energy < best_energy_overall - 1e-9
                            final_check_energy = current_energy
                            # Always recalculate under lock for safety before accepting new best
                            try
                                final_check_energy = energy(sg, reshape(current_config, 1, N))
                            catch e
                                 @warn "Error recalculating energy under lock for config $c: $e"
                                 final_check_energy = NaN # Don't update if recalculation fails
                            end

                            # Final confirmation with potentially recalculated energy
                            if !isnan(final_check_energy) && final_check_energy < best_energy_overall - 1e-9
                                old_best_energy = best_energy_overall
                                best_energy_overall = final_check_energy
                                best_config_overall = copy(current_config) # Store copy

                                # --- Save Best Config to File ---
                                if save_best_to_file && final_check_energy < -93847.0
                                    try
                                        fname = @sprintf("%s_E%.4f_beta%.3f_step%d.txt", filename_prefix, best_energy_overall, beta, step)
                                        open(fname, "w") do f
                                            writedlm(f, reshape(best_config_overall, 1, :), ' ')
                                        end
                                        if verbose
                                            @printf("Step %d (β=%.3f), Cfg %d (Thr %d): New best E found! %.5f < %.5f. Saved to %s\n",
                                                    step, beta, c, Threads.threadid(), best_energy_overall, old_best_energy, fname)
                                            flush(stdout)
                                        end
                                    catch e
                                        @warn "Could not save best config to file '$fname': $e"
                                    end
                                else # Print message even if not saving
                                     if verbose
                                        @printf("Step %d (β=%.3f), Cfg %d (Thr %d): New best E found! %.5f < %.5f\n",
                                                step, beta, c, Threads.threadid(), best_energy_overall, old_best_energy)
                                        flush(stdout)
                                     end
                                end # end if save_best_to_file
                            end # end final confirmation check
                        end # end re-check under lock
                    finally
                        unlock(best_lock)
                    end # end try-finally lock
                end # end check if potentially better
            end # end if !isnan(current_energy)

        end # End PARALLEL loop over population configs

        # --- Resampling Step (Sequential) ---
        # Filter out any NaN energies before resampling
        valid_indices = findall(!isnan, energies)
        if length(valid_indices) < population_size
             @warn "Step $step (β=%.3f): Found $(population_size - length(valid_indices)) NaN energies before resampling. Proceeding with valid ones."
             if isempty(valid_indices)
                  @error "Step $step (β=%.3f): All energies became NaN. Cannot resample. Aborting."
                  # Decide how to handle: return current best? error out?
                  # Returning current best found so far:
                  lock(best_lock)
                  try return copy(best_config_overall) finally unlock(best_lock) end
             end
        end
        current_energies = energies[valid_indices]
        current_configs = configs[valid_indices] # Get corresponding configs

        # Calculate Gibbs weights (robustly)
        min_E_pop = minimum(current_energies)
        weights = exp.(-beta .* (current_energies .- min_E_pop))
        sum_weights = sum(weights)

        if sum_weights <= 0.0 || isnan(sum_weights) || isinf(sum_weights)
            @warn "Step $step (β=%.3f): Problem with resampling weights (sum= $sum_weights). Possibly all energies are identical or very large/small. Performing uniform resampling."
            # Fallback: If weights are problematic, sample uniformly from valid configs
            indices_to_keep = rand(valid_indices, population_size) # Sample indices from the original valid set
            new_configs = [copy(configs[i]) for i in indices_to_keep]
            new_energies = [energies[i] for i in indices_to_keep] # Keep their energies
        else
            # Perform weighted sampling (multinomial resampling)
            # sample needs indices 1:length(weights) and probabilities
            probabilities = weights ./ sum_weights
             # Ensure probabilities sum to 1 approximately, handle potential small numerical errors
            if !isapprox(sum(probabilities), 1.0, atol=1e-9)
                 @warn "Step $step (β=%.3f): Resampling probabilities do not sum to 1 (sum= $(sum(probabilities))). Renormalizing."
                 probabilities ./= sum(probabilities) # Force normalization
            end

            # Sample indices from the *valid* configurations based on probabilities
            sampled_indices_in_valid = sample(1:length(valid_indices), Weights(probabilities), population_size)

            # Create the new population based on the sampled indices
            new_configs = [copy(current_configs[i]) for i in sampled_indices_in_valid]
            new_energies = [current_energies[i] for i in sampled_indices_in_valid] # Keep the energies of the chosen configs
        end

        # Replace the old population with the new resampled population
        configs = new_configs
        energies = new_energies
        @assert length(configs) == population_size "Population size changed after resampling!"
        @assert length(energies) == population_size "Energies size changed after resampling!"


        # --- Progress Reporting ---
        if verbose && (step % (max(1, num_annealing_steps ÷ 20)) == 0 || step == 1 || step == num_annealing_steps)
             local_best_e = 0.0
             lock(best_lock)
             try local_best_e = best_energy_overall finally unlock(best_lock) end

             # Filter out NaNs when finding current minimum energy in population
             current_min_E_pop = minimum(filter(!isnan, energies); init=Inf)
             current_avg_E_pop = mean(filter(!isnan, energies))

             @printf("Step %d/%d (β=%.4f): Pop min E ≈ %.4f, Pop avg E ≈ %.4f, Best E = %.4f\n",
                     step, num_annealing_steps, beta, current_min_E_pop, current_avg_E_pop, local_best_e)
             flush(stdout)
        end

    end # End main PA annealing loop

    # --- Final Check and Return ---
    final_best_config = Int[]
    final_best_energy = NaN # Use NaN to indicate if not properly set
    lock(best_lock)
    try
        final_best_config = copy(best_config_overall)
        final_best_energy = best_energy_overall
    finally
        unlock(best_lock)
    end

    # Final verification if config is not empty
    final_check_energy = NaN
    if !isempty(final_best_config)
        try
            final_check_energy = energy(sg, reshape(final_best_config, 1, N))
        catch e
             @warn "Error during final energy check: $e"
        end
    else
        # This can happen if N=0 or if initialization failed catastrophically
         @warn "Final best config is empty!"
         return Int[] # Return empty as per initial check for N=0
    end

    if verbose
        @printf("\nPopulation Annealing finished.\n")
        if !isnan(final_best_energy)
             @printf("Best energy tracked during run: %.4f\n", final_best_energy)
        else
             @printf("Best energy tracking seems to have failed (NaN).\n")
        end
        if !isnan(final_check_energy)
            @printf("Final check energy of stored best_config: %.4f\n", final_check_energy)
        else
             @printf("Final check energy calculation failed.\n")
        end
        flush(stdout)
    end

    # Decide which energy to trust if they differ or one failed
    final_confirmed_energy = NaN
    if !isnan(final_check_energy)
        if !isnan(final_best_energy) && !isapprox(final_check_energy, final_best_energy, atol=1e-6, rtol=1e-6)
            @warn "Potential issue: Final check energy $final_check_energy differs from tracked best energy $final_best_energy. Trusting final check."
        end
        final_confirmed_energy = final_check_energy # Trust re-calculated if available
    elseif !isnan(final_best_energy)
         @warn "Using tracked best energy $final_best_energy as final check failed."
         final_confirmed_energy = final_best_energy
    else
        @error("Both tracked best energy and final check energy are invalid (NaN).")
        # Depending on requirements, might return empty config or error
        # return Int[]
    end


    if verbose && !isnan(final_confirmed_energy)
        @printf("Final confirmed best energy: %.4f\n", final_confirmed_energy)
        flush(stdout)
    end

    # Return the best configuration found
    return final_best_config
end


# --- Test Cases ---

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

function spin_glass_f(n::Int)
    g1 = UnitDiskGraph(fullerene(), sqrt(n))
    # Use Float64 for consistency with energy calculations
    coupling = ones(Float64, ne(g1))
    bias = zeros(Float64, nv(g1))
    @assert length(bias) == nv(g1) "Bias vector length ($(length(bias))) mismatch with Nv ($(nv(g1)))"
    return SpinGlass(g1, coupling, bias)
end
sg1 = spin_glass_f(5) 
result_sg1_pa = @time population_annealing_solver(sg1,
                                     population_size=10, # Similar to num_replicas
                                     beta_init = 1.0/10.0,  # Start hot
                                     beta_final = 1.0/0.1,   # End cold (adjust based on PT T_min/T_max)
                                     num_annealing_steps = 500, # Number of beta steps
                                     sweeps_per_step = 10,    # Sweeps per config per beta
                                     verbose=true,
                                     verification_freq=500,
                                     save_best_to_file=true,
                                     filename_prefix="pa_sg1_5_2")
                                
energy_sg1_pa = energy(sg1, reshape(result_sg1_pa, 1, nv(sg1.graph)))
println("\nsg1 PA Result Energy: ", energy_sg1_pa)