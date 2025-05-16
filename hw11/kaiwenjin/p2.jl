# Assume the number of hidden states is 2
using LinearAlgebra

# Define the Baum-Welch algorithm function
function baum_welch(observations, n_states, max_iter=100, tol=1e-6)
    n_obs = length(observations)
    unique_obs = sort(unique(observations))
    n_unique_obs = length(unique_obs)
    
    # Initialize parameters
    A = rand(n_states, n_states)  # Transition matrix
    A ./= sum(A, dims=2)          # Normalize
    
    B = rand(n_states, n_unique_obs)  # Emission matrix
    B ./= sum(B, dims=2)              # Normalize
    
    T = rand(n_states)           # Initial state distribution
    T ./= sum(T)                 # Normalize
    
    log_likelihood_prev = -Inf
    
    for iter in 1:max_iter
        # Forward algorithm
        α = zeros(n_states, n_obs)
        scale = zeros(n_obs)
        
        # Initialize
        for s in 1:n_states
            obs_idx = findfirst(isequal(observations[1]), unique_obs)
            α[s, 1] = T[s] * B[s, obs_idx]
        end
        scale[1] = sum(α[:, 1])
        α[:, 1] ./= scale[1]
        
        # Recursion
        for t in 2:n_obs
            for s in 1:n_states
                α[s, t] = sum(α[s_prev, t-1] * A[s_prev, s] for s_prev in 1:n_states) * 
                          B[s, findfirst(isequal(observations[t]), unique_obs)]
            end
            scale[t] = sum(α[:, t])
            α[:, t] ./= scale[t]
        end
        
        # Backward algorithm
        β = zeros(n_states, n_obs)
        β[:, end] .= 1.0 / scale[end]
        
        for t in n_obs-1:-1:1
            for s in 1:n_states
                β[s, t] = sum(A[s, s_next] * 
                          B[s_next, findfirst(isequal(observations[t+1]), unique_obs)] * 
                          β[s_next, t+1] for s_next in 1:n_states) / scale[t]
            end
        end
        
        # Calculate γ and ξ
        γ = zeros(n_states, n_obs)
        ξ = zeros(n_states, n_states, n_obs-1)
        
        for t in 1:n_obs-1
            denom = sum(α[s_prev, t] * A[s_prev, s] * 
                      B[s, findfirst(isequal(observations[t+1]), unique_obs)] * 
                      β[s, t+1] for s_prev in 1:n_states, s in 1:n_states)
            
            for s_prev in 1:n_states
                for s in 1:n_states
                    ξ[s_prev, s, t] = α[s_prev, t] * A[s_prev, s] * 
                                     B[s, findfirst(isequal(observations[t+1]), unique_obs)] * 
                                     β[s, t+1] / denom
                end
            end
        end
        
        for t in 1:n_obs
            γ[:, t] = α[:, t] .* β[:, t]
            γ[:, t] ./= sum(γ[:, t])
        end
        
        # Update parameters
        T_new = γ[:, 1]
        
        A_new = zeros(size(A))
        for s_prev in 1:n_states
            for s in 1:n_states
                A_new[s_prev, s] = sum(ξ[s_prev, s, t] for t in 1:n_obs-1) / 
                                   sum(γ[s_prev, t] for t in 1:n_obs-1)
            end
        end
        
        B_new = zeros(size(B))
        for s in 1:n_states
            for (obs_idx, obs) in enumerate(unique_obs)
                B_new[s, obs_idx] = sum(γ[s, t] for t in 1:n_obs if observations[t] == obs) / 
                                   sum(γ[s, t] for t in 1:n_obs)
            end
        end
        
        # Calculate log likelihood
        log_likelihood = sum(log.(scale))
        
        # Check convergence
        if abs(log_likelihood - log_likelihood_prev) < tol
            println("Converged at iteration $iter")
            break
        end
        
        log_likelihood_prev = log_likelihood
        
        # Update parameters
        A = A_new
        B = B_new
        T = T_new
        
        if iter == max_iter
            println("Reached maximum iterations")
        end
    end
    
    return A, B, T
end

# Test the Baum-Welch algorithm
observations = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]  # Observation sequence
n_states = 2                                          # Number of hidden states

A, B, T = baum_welch(observations, n_states)

println("Transition matrix A:")
display(A)
#=
2×2 Matrix{Float64}:
 4.11469e-25  1.0
 1.0          1.23247e-40
=#
println("\nEmission matrix B:")
display(B)
#=
2×2 Matrix{Float64}:
 1.0          4.11469e-25
 9.49501e-41  1.0
=#
println("\nInitial distribution T:")
display(T)
#=
2-element Vector{Float64}:
 1.0
 4.632125167139347e-43
=#
