using LinearAlgebra

#task2

function baum_welch(obs::Vector{Int}, num_states::Int; max_iter::Int=100, tol::Float64=1e-6)
    N = length(obs)
    M = maximum(obs) + 1  # 观测符号数量
    A = rand(num_states, num_states)
    B = rand(num_states, M)
    π = rand(num_states)

    A ./= sum(A, dims=2)
    B ./= sum(B, dims=2)
    π ./= sum(π)

    prev_ll = -Inf

    for iter in 1:max_iter
        # Forward
        α = zeros(N, num_states)
        α[1, :] .= π .* B[:, obs[1]+1]
        for t in 2:N
            for j in 1:num_states
                α[t, j] = sum(α[t-1, i] * A[i, j] for i in 1:num_states) * B[j, obs[t]+1]
            end
        end

        # Backward
        β = ones(N, num_states)
        for t in (N-1):-1:1
            for i in 1:num_states
                β[t, i] = sum(A[i, j] * B[j, obs[t+1]+1] * β[t+1, j] for j in 1:num_states)
            end
        end

        # Gamma and Xi
        γ = α .* β
        γ ./= sum(γ, dims=2)

        ξ = zeros(num_states, num_states, N-1)
        for t in 1:N-1
            denom = sum(α[t, i] * A[i, j] * B[j, obs[t+1]+1] * β[t+1, j] for i in 1:num_states, j in 1:num_states)
            for i in 1:num_states, j in 1:num_states
                ξ[i, j, t] = α[t, i] * A[i, j] * B[j, obs[t+1]+1] * β[t+1, j] / denom
            end
        end

        # Update π
        π .= γ[1, :]

        # Update A
        for i in 1:num_states
            for j in 1:num_states
                numer = sum(ξ[i, j, t] for t in 1:N-1)
                denom = sum(γ[t, i] for t in 1:N-1)
                A[i, j] = numer / denom
            end
        end

        # Update B
        for j in 1:num_states
            denom = sum(γ[t, j] for t in 1:N)
            for k in 0:M-1
                numer = sum(γ[t, j] for t in 1:N if obs[t] == k)
                B[j, k+1] = numer / denom
            end
        end

        # Normalize
        A ./= sum(A, dims=2)
        B ./= sum(B, dims=2)

        # Check log-likelihood for convergence
        ll = log(sum(α[end, :]))
        println("Iter $iter | Log-Likelihood: ", round(ll, digits=6))
        if abs(ll - prev_ll) < tol
            println("✅ Converged at iteration $iter")
            break
        end
        prev_ll = ll
    end

    return A, B
end

# --------------------
# 测试代码
# --------------------

obs = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
num_states = 2

A, B = baum_welch(obs, num_states)

println("\n✅ Learned Transition Matrix A:")
display(A)

println("\n✅ Learned Emission Matrix B:")
display(B)
