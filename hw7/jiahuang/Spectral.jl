using LinearAlgebra
using Arpack
using Plots
using ProgressMeter # Optional
using LinearMaps
using Printf # For better formatting in output

# --- Graph Generation Functions ---

function create_adj_list(N::Int, edges::Vector{Tuple{Int, Int}})
    adj = [Int[] for _ in 1:N]
    for (u, v) in edges
        # Ensure edges are within bounds
        if 1 <= u <= N && 1 <= v <= N
            push!(adj[u], v)
            push!(adj[v], u) # Assuming undirected graph
        else
            @warn "Edge ($u, $v) outside bounds for N=$N"
        end
    end
    # Remove duplicate neighbors if any edge was added twice
    for i in 1:N
        unique!(adj[i])
    end
    return adj
end

function create_triangle_graph(N::Int)
    N > 0 || return Vector{Vector{Int}}[] # Handle N=0
    N % 2 == 0 || throw(ArgumentError("N must be even for triangle ladder graph (current implementation)"))
    Nhalf = N ÷ 2
    edges = Tuple{Int, Int}[]

    # Horizontal top and bottom
    for i in 1:Nhalf-1
        push!(edges, (i, i+1))           # Top row
        push!(edges, (i+Nhalf, i+1+Nhalf)) # Bottom row
    end

    # Vertical
    for i in 1:Nhalf
        push!(edges, (i, i+Nhalf))
    end

    # Diagonals (forming triangles)
    for i in 1:Nhalf-1
         push!(edges, (i, i+1+Nhalf)) # Connects top i to bottom i+1
         push!(edges, (i+1, i+Nhalf)) # Connects top i+1 to bottom i
    end

    return create_adj_list(N, edges)
end

function create_square_graph(N::Int)
    N > 0 || return Vector{Vector{Int}}[] # Handle N=0
    N % 2 == 0 || throw(ArgumentError("N must be even for square ladder graph (current implementation)"))
    Nhalf = N ÷ 2
    edges = Tuple{Int, Int}[]

    # Horizontal top and bottom
    for i in 1:Nhalf-1
        push!(edges, (i, i+1))           # Top row
        push!(edges, (i+Nhalf, i+1+Nhalf)) # Bottom row
    end

    # Vertical
    for i in 1:Nhalf
        push!(edges, (i, i+Nhalf))
    end

    return create_adj_list(N, edges)
end

function create_diamond_graph(N::Int)
    # 1D chain with nearest and next-nearest neighbor connections
    N > 0 || return Vector{Vector{Int}}[] # Handle N=0
    if N == 1 return [Int[]] end # Handle N=1
    if N == 2 return create_adj_list(N, [(1,2)]) end # Handle N=2

    edges = Tuple{Int, Int}[]
    # Nearest neighbors
    for i in 1:N-1
        push!(edges, (i, i+1))
    end
    # Next-nearest neighbors (forms diamonds)
    for i in 1:N-2
        push!(edges, (i, i+2))
    end

    return create_adj_list(N, edges)
end

# --- State Representation ---
# Map integer index (0 to 2^N-1) to spin state (Vector{Int} of +/-1) and back

function index_to_state(idx_zero_based::Int, N::Int)
    # Input: 0-based index (0 to 2^N-1)
    state = zeros(Int, N)
    for i in 1:N
        # Check the (i-1)-th bit
        state[i] = ((idx_zero_based >> (i - 1)) & 1) == 1 ? 1 : -1
    end
    return state
end

function state_to_index(state::Vector{Int})
    # Output: 1-based index (1 to 2^N)
    N = length(state)
    idx_zero_based = 0
    for i in 1:N
        if state[i] == 1
            idx_zero_based |= (1 << (i - 1)) # Set the (i-1)-th bit
        end
    end
    return idx_zero_based + 1 # Return 1-based index for Julia arrays
end

# --- Energy Calculation ---
const J = 1.0 # Anti-ferromagnetic coupling

function calculate_delta_H(state::Vector{Int}, site_i::Int, adj::Vector{Vector{Int}})
    # Calculates the change in energy if spin at site_i is flipped
    # H = -J * sum_{<j,k>} s_j s_k
    # When s_i flips to -s_i:
    # Change comes only from terms involving s_i.
    # Original energy part = -J * s_i * sum_{k adjacent to i} s_k
    # New energy part      = -J * (-s_i) * sum_{k adjacent to i} s_k
    # Delta H = New - Original = 2 * J * s_i * sum_{k adjacent to i} s_k
    # *** DEBUG NOTE: The original code had -2.0 * J * si * neighbor_sum. Let's re-derive carefully.
    # Let H(S) be the energy of state S. Let S' be state S with spin i flipped.
    # H(S) = C - J * state[site_i] * sum(state[neighbor] for neighbor in adj[site_i])
    # H(S') = C - J * (-state[site_i]) * sum(state[neighbor] for neighbor in adj[site_i])
    # ΔH = H(S') - H(S)
    # ΔH = [C + J*state[site_i]*sum(...)] - [C - J*state[site_i]*sum(...)]
    # ΔH = 2 * J * state[site_i] * sum(state[neighbor] for neighbor in adj[site_i])
    # The previous implementation had a sign error. Let's correct it.

    si = state[site_i]
    neighbor_spin_sum = 0
    if site_i <= length(adj) && site_i >= 1 && !isempty(adj[site_i]) # Check validity
        for neighbor in adj[site_i]
            neighbor_spin_sum += state[neighbor]
        end
    end
    # Use Float64 for the result to interact correctly with beta
    return 2.0 * J * Float64(si * neighbor_spin_sum)
end

# --- Matrix-Free Operator for Transition Matrix P ---

struct IsingTransitionOperator
    N::Int
    T::Float64
    adj::Vector{Vector{Int}}
    dim::Int # 2^N
    beta::Float64 # Precompute beta
end

# Constructor
function IsingTransitionOperator(N::Int, T::Float64, adj::Vector{Vector{Int}})
    dim = 2^N
    beta = T > 0 ? 1.0 / T : Inf
    return IsingTransitionOperator(N, T, adj, dim, beta)
end


# Define the multiplication P*x for the LinearMap
function (P_op::IsingTransitionOperator)(x::AbstractVector)
    N = P_op.N
    adj = P_op.adj
    dim = P_op.dim
    beta = P_op.beta
    # Use ComplexF64 for compatibility with eigs, even if result should be real
    y = zeros(ComplexF64, dim)

    # Iterate through all source states (index s_idx corresponds to state s)
    # Julia arrays are 1-based, state indices used internally are 0 to 2^N-1
    for s_idx_zero_based in 0:(dim - 1)
        s_idx = s_idx_zero_based + 1 # 1-based index for array access
        x_s = x[s_idx]

        # Optimization: skip if input vector component is near zero
        if abs(x_s) < 1e-16 continue end

        s_state = index_to_state(s_idx_zero_based, N)
        total_leaving_prob = 0.0

        # Consider flipping each spin
        for i in 1:N
            # Calculate energy change for flipping spin i
            delta_H = calculate_delta_H(s_state, i, adj)

            # Acceptance probability (Metropolis)
            # If delta_H <= 0, flip is always accepted (prob=1)
            # If delta_H > 0, accepted with prob exp(-beta*delta_H)
            acceptance_prob = delta_H <= 0 ? 1.0 : exp(-beta * delta_H)
            # The previous min(1.0, ...) is equivalent and also correct. Keep current form.

            # Probability of proposing flip i (1/N) AND accepting
            prob_flip_i = (1.0 / N) * acceptance_prob
            total_leaving_prob += prob_flip_i

            # Find the target state s'
            s_prime_state = copy(s_state)
            s_prime_state[i] *= -1
            s_prime_idx = state_to_index(s_prime_state) # Get 1-based index

            # Add contribution P(s'|s) * x_s to y[s']
            # P(s'|s) = prob_flip_i when s' is reached by flipping spin i from s
            y[s_prime_idx] += prob_flip_i * x_s
        end

        # Probability of staying in state s, P(s|s) = 1 - sum_{s' != s} P(s'|s)
        # Here, sum_{s' != s} P(s'|s) is the total probability of proposing *and* accepting any flip
        prob_stay = 1.0 - total_leaving_prob
        # Add contribution P(s|s) * x_s to y[s]
        y[s_idx] += prob_stay * x_s
    end
    return y
end


# --- Spectral Gap Calculation ---

function calculate_spectral_gap(N::Int, T::Float64, adj::Vector{Vector{Int}}; nev=3, tol=1e-9, maxiter=1000)
    # Increased nev slightly to better resolve potential near-degeneracies around 1
    # Increased maxiter and decreased tol for potentially better accuracy, esp. at low T
    if N <= 0 return NaN end # Handle N=0 or negative
    dim = 2^N
    if dim == 1 return 0.0 end # Handle N=1 -> dim=2. If N=0, dim=1. Let's handle N=0 earlier.

    println("Calculating gap for N=$N, T=$T, dim=$dim")

    # Define the LinearMap using the custom operator structure
    P_op = IsingTransitionOperator(N, T, adj)
    # P should map Real vectors to Real vectors, but use ComplexF64 for eigs stability
    P_map = LinearMap{ComplexF64}(P_op, dim, ishermitian=false)
    # Although P is not Hermitian, its eigenvalues are real because it's similar
    # to a Hermitian matrix via a similarity transformation involving sqrt(pi_i/pi_j)
    # where pi is the equilibrium distribution. Arpack should handle this.

    try
        # Use Arpack to find the largest magnitude eigenvalues
        # For Markov matrices, eigenvalues have |λ| <= 1. We expect λ₁=1.
        # We need λ₂, which should be the eigenvalue with the second largest *real part*.
        # :LR finds largest real part.
        # Find a few eigenvalues near 1 to be safe.
        evals, evecs, nconv, niter, nmult, resid = Arpack.eigs(P_map; nev=nev, which=:LR, tol=tol, maxiter=maxiter)

        # Filter out potentially spurious complex eigenvalues if theory guarantees real
        real_evals = real(evals)

        # Sort eigenvalues by real part in descending order
        sort!(real_evals, rev=true)

        # Check convergence and number of eigenvalues found
        if nconv < 2
             @warn "Arpack converged fewer than 2 eigenvalues (nconv=$nconv) for N=$N, T=$T. Gap calculation may be unreliable."
             return NaN
        end

        lambda1 = real_evals[1]
        lambda2 = real_evals[2]

        # Check if the largest eigenvalue is close to 1
        if !isapprox(lambda1, 1.0, atol=1e-6)
             @warn "Largest eigenvalue is not 1 (λ₁ = $lambda1) for N=$N, T=$T. Check implementation, Arpack convergence (niter=$niter, nmult=$nmult), or tolerance."
             # It might be that the second eigenvalue is actually 1 (e.g., disconnected Markov chain)
             # or simply numerical error / lack of convergence.
        end

        # Ensure lambda2 is not numerically > 1 due to noise/tolerance issues
        lambda2 = min(lambda2, 1.0)

        # The gap is 1 - lambda_2, where lambda_2 is the second largest eigenvalue *magnitude*
        # for reversible Markov chains, or second largest *real part* more generally.
        # Since lambda_1 = 1, the gap is 1 - Re(lambda_2).
        gap = 1.0 - lambda2

        # Ensure gap is non-negative
        gap = max(0.0, gap)

        @printf "N=%d, T=%.2f: λ₁ ≈ %.6f, λ₂ ≈ %.6f, Gap = %.6f (nconv=%d, niter=%d)\n" N T lambda1 lambda2 gap nconv niter
        return gap
    catch e
        # Catch potential errors during eigs computation
        if e isa Arpack.ARPACKException
             @error "Arpack failed for N=$N, T=$T: $(e.info)"
        else
             @error "Error during eigenvalue calculation for N=$N, T=$T: $e"
        end
        return NaN # Return NaN on failure
    end
end

# --- Main Analysis ---

function run_analysis()
    # --- Task 1: Gap vs Temperature ---
    N_fixed = 8 # Keep N=8 as it's manageable
    T_values = 0.1:0.1:2.5 # Extend T range slightly
    topologies = ["Triangles", "Squares", "Diamonds"]
    results_T = Dict{String, Vector{Float64}}()

    println("\n--- Task 1: Gap vs Temperature (N = $N_fixed) ---")
    println("Corrected ΔH formula used.")
    for topo_name in topologies
        println("\nTopology: $topo_name")
        adj = if topo_name == "Triangles"
            create_triangle_graph(N_fixed)
        elseif topo_name == "Squares"
            create_square_graph(N_fixed)
        else # Diamonds
            create_diamond_graph(N_fixed)
        end

        gaps = Float64[]
        # Use ProgressMeter if available
        prog = Progress(length(T_values), 1, "Calculating gaps for $topo_name (N=$N_fixed)...")
        for T in T_values
            gap = calculate_spectral_gap(N_fixed, T, adj)
            push!(gaps, gap)
            ProgressMeter.next!(prog; showvalues = [(:T, T), (:gap, gap)]) # Show current T and gap
        end
        results_T[topo_name] = gaps
    end

    # Plotting Task 1
    plot_T = plot(title="Spectral Gap vs Temperature (N=$N_fixed, Corrected ΔH)", xlabel="Temperature T", ylabel="Spectral Gap (1 - λ₂)", legend=:topleft) # Legend position might be better top-left
    for topo_name in topologies
        # Filter NaNs just in case Arpack failed for some T
        valid_indices = .!isnan.(results_T[topo_name])
        if any(valid_indices)
             plot!(plot_T, T_values[valid_indices], results_T[topo_name][valid_indices], label=topo_name, marker=:circle, markersize=3)
        else
             println("No valid gap data to plot for $topo_name vs T.")
        end
    end
    savefig(plot_T, "spectral_gap_vs_T_N$(N_fixed)_corrected.png")
    try
        display(plot_T)
    catch e
        println("Could not display plot 1 (plotting backend issue?): $e")
    end


    # --- Task 2: Gap vs System Size ---
    T_fixed = 1.0 # Use a higher temperature (T=1.0) where gaps are likely larger and more distinct from 0
    # T=0.1 was showing gap=0 numerically for many cases, making comparison difficult.
    # N must be even for Triangles/Squares as defined.
    # Diamonds works for any N > 1. Let's use only even N for consistency.
    N_values = 4:2:14 # Keep range N=4 to N=14 (2^14 = 16384 states)
    results_N = Dict{String, Vector{Float64}}()

    println("\n--- Task 2: Gap vs System Size (T = $T_fixed) ---")
    println("Corrected ΔH formula used.")
     for topo_name in topologies
        println("\nTopology: $topo_name")
        gaps = Float64[]
        prog = Progress(length(N_values), 1, "Calculating gaps for $topo_name (T=$T_fixed)...")
        for N in N_values
             adj = if topo_name == "Triangles"
                 create_triangle_graph(N)
             elseif topo_name == "Squares"
                 create_square_graph(N)
             else # Diamonds
                 create_diamond_graph(N)
             end
             gap = calculate_spectral_gap(N, T_fixed, adj)
             push!(gaps, gap)
             ProgressMeter.next!(prog; showvalues = [(:N, N), (:gap, gap)]) # Show current N and gap
        end
         results_N[topo_name] = gaps
     end

    # Plotting Task 2
    plot_N = plot(title="Spectral Gap vs System Size (T=$T_fixed, Corrected ΔH)", xlabel="System Size N", ylabel="Spectral Gap (1 - λ₂)", legend=:topright, yaxis=:log) # Log scale for gap is standard
    for topo_name in topologies
        valid_indices = .!isnan.(results_N[topo_name]) # Filter out NaN if Arpack failed
        if any(valid_indices)
            plot!(plot_N, N_values[valid_indices], results_N[topo_name][valid_indices], label=topo_name, marker=:circle, markersize=3)
        else
            println("No valid gap data to plot for $topo_name vs N.")
        end
    end
    # Add theoretical expectation (e.g., 1/N^z) if known, for context. (Optional)
    # Example: plot!(plot_N, N_values, N_values.^(-2.0), label="~1/N^2", linestyle=:dash)
    savefig(plot_N, "spectral_gap_vs_N_T$(T_fixed)_corrected.png")
     try
        display(plot_N)
    catch e
        println("Could not display plot 2 (plotting backend issue?): $e")
    end

end

# --- Run the analysis ---
run_analysis()

println("\nAnalysis complete. Plots saved.")