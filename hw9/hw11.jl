1.
using Einsum
using LinearAlgebra

function matrix_vector_multiplication()
    A = rand(3, 3)
    v = rand(3)
    
    @einsum C[i] := A[i,j] * v[j]
    
    @assert C ≈ A * v
    return C
end

function matrix_trace()
    A = rand(3, 3)

    @einsum C := A[i,i]

    @assert C ≈ tr(A)
    return C
end

function matrix_transpose()
    A = rand(3, 3)

    @einsum C[j,i] := A[i,j]
    
    @assert C ≈ transpose(A)
    return C
end

function row_summation()
    A = rand(3, 3)
    
    @einsum C[j] := A[i,j]
    
    @assert C ≈ sum(A, dims=1)[:]
    return C
end

function matrix_chain_multiplication()
    A1 = rand(2, 3)
    A2 = rand(3, 4)
    A3 = rand(4, 5)
    A4 = rand(5, 6)
    A5 = rand(6, 7)
    
    @einsum C[i,n] := A1[i,j] * A2[j,k] * A3[k,l] * A4[l,m] * A5[m,n]
    
    @assert C ≈ A1 * A2 * A3 * A4 * A5
    return C
end

function hadamard_product()
    A = rand(3, 3)
    B = rand(3, 3)
    @einsum C[i,j] := A[i,j] * B[i,j]
    @assert C ≈ A .* B
    return C
end

function main()
    results = (
        matrix_vector_multiplication(),
        matrix_trace(),
        matrix_transpose(),
        row_summation(),
        matrix_chain_multiplication(),
        hadamard_product()
    )
    return results
end

main()

2.
using LinearAlgebra
using Statistics

function initialize_parameters()
    A = [0.6 0.4; 0.3 0.7]

    B = [0.7 0.3; 0.2 0.8]

    π = [0.5, 0.5]
    
    return A, B, π
end

function forward(A, B, π, observations)
    T = length(observations)
    N = size(A, 1)
    α = zeros(N, T)

    α[:, 1] = π .* B[:, observations[1]+1] 

    for t in 2:T
        for j in 1:N
            α[j, t] = sum(α[i, t-1] * A[i, j] for i in 1:N) * B[j, observations[t]+1]
        end
    end
    
    return α
end

function backward(A, B, observations)
    T = length(observations)
    N = size(A, 1)
    β = zeros(N, T)
    
    β[:, T] .= 1.0
    
    for t in T-1:-1:1
        for i in 1:N
            β[i, t] = sum(A[i, j] * B[j, observations[t+1]+1] * β[j, t+1] for j in 1:N)
        end
    end
    
    return β
end

function baum_welch(observations; max_iter=100, tol=1e-6)
    A, B, π = initialize_parameters()
    N = size(A, 1)
    T = length(observations)
    prev_loglik = -Inf
    
    for iter in 1:max_iter
        α = forward(A, B, π, observations)
        β = backward(A, B, observations)
        
        ξ = zeros(N, N, T-1)
        γ = zeros(N, T)
        
        for t in 1:T
            γ[:, t] = α[:, t] .* β[:, t]
            γ[:, t] ./= sum(γ[:, t])
        end
        
        for t in 1:T-1
            for i in 1:N
                for j in 1:N
                    ξ[i, j, t] = α[i, t] * A[i, j] * B[j, observations[t+1]+1] * β[j, t+1]
                end
            end
            ξ[:, :, t] ./= sum(ξ[:, :, t])
        end
        
        for i in 1:N
            for j in 1:N
                A[i, j] = sum(ξ[i, j, t] for t in 1:T-1) / sum(γ[i, t] for t in 1:T-1)
            end
        end

        for j in 1:N
            for k in 0:1 
                numerator = sum(γ[j, t] for t in 1:T if observations[t] == k)
                denominator = sum(γ[j, t] for t in 1:T)
                B[j, k+1] = numerator / denominator
            end
        end
        
        loglik = log(sum(α[:, T]))
        if abs(loglik - prev_loglik) < tol
            println("Converged at iteration $iter")
            break
        end
        prev_loglik = loglik
    end
    
    return A, B
end
observations = [mod(i, 2) for i in 1:20]

A_learned, B_learned = baum_welch(observations)

println("Learned Transition Matrix A:")
display(round.(A_learned, digits=4))
println("\nLearned Emission Matrix B:")
display(round.(B_learned, digits=4))

println("\nVerification:")
println("A rows sum to 1: ", all(sum(A_learned, dims=2) .≈ 1.0))
println("B rows sum to 1: ", all(sum(B_learned, dims=2) .≈ 1.0))