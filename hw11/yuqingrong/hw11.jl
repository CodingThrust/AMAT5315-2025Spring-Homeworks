### 1.(Tensor network representation)
using OMEinsum
# (1) Matrix-vector multiplication
A = [1 2; 3 4]
v = [1, 2]
ein"ij,j->i"(A, v)

# (2) Matrix trace
A = [1 2; 3 4]
ein"ii->"(A)

# (3) Matrix transpose
A = [1 2; 3 4]
ein"ij->ji"(A)


#(4) Sum over the rows of a matrix
A = [1 2; 3 4]
ein"ij->j"(A)

#(5) Multiplication of 5 matrices in a row
A1 = [1 2; 3 4]
A2 = [1 2; 3 4]
A3 = [1 2; 3 4] 
A4 = [1 2; 3 4]
A5 = [1 2; 3 4]
ein"ij,jk,kl,lm,mn->in"(A1, A2, A3, A4, A5)

#(6) Hadamard product
A = [1 2; 3 4]
B = [5 6; 7 8]
ein"ij,ij->ij"(A, B)



### 2. (Hidden Markov Model) 

using Random, HiddenMarkovModels

function init_matrices(n_states, n_emissions)

    A = rand(n_states, n_states)
    A = A ./ sum(A, dims=2)
 
    B = rand(n_states, n_emissions)
    B = B ./ sum(B, dims=2)
    
    return A, B
end


function forward(obs, A, B)
    T = length(obs)
    N = size(A,1)
    α = zeros(T, N)
    

    α[1,:] = fill(1/N, N) .* B[:,obs[1]+1]
    

    for t in 2:T
        for j in 1:N
            α[t,j] = B[j,obs[t]+1] * sum(α[t-1,:] .* A[:,j])
        end
    end
    
    return α
end


function backward(obs, A, B)
    T = length(obs)
    N = size(A,1)
    β = zeros(T, N)
    
    # Initialize
    β[T,:] .= 1
    
    # Iterate
    for t in T-1:-1:1
        for i in 1:N
            β[t,i] = sum(A[i,:] .* B[:,obs[t+1]+1] .* β[t+1,:])
        end
    end
    
    return β
end


function baumwelch(obs, n_states, max_iter=1000, tol=1e-6)
   
    A, B = init_matrices(n_states, 2)  
    
    for iter in 1:max_iter
        old_A = copy(A)
        old_B = copy(B)
        
       
        α = forward(obs, A, B)
        β = backward(obs, A, B)
        
        
        γ = α .* β
        γ = γ ./ sum(γ, dims=2)
        
       
        T = length(obs)
        ξ = zeros(T-1, n_states, n_states)
        for t in 1:T-1
            for i in 1:n_states
                for j in 1:n_states
                    ξ[t,i,j] = α[t,i] * A[i,j] * B[j,obs[t+1]+1] * β[t+1,j]
                end
            end
            ξ[t,:,:] ./= sum(ξ[t,:,:])
        end
        
      
        A = sum(ξ, dims=1)[1,:,:] ./ sum(γ[1:end-1,:], dims=1)
        
   
        for j in 1:n_states
            for k in 0:1
                B[j,k+1] = sum(γ[obs.==k,j]) / sum(γ[:,j])
            end
        end
        
        # Check convergence
        if maximum(abs.(A - old_A)) < tol && maximum(abs.(B - old_B)) < tol
            break
        end
    end
    
    return A, B
end


obs = repeat([0,1], 10) 


A, B = baumwelch(obs, 2)

println(A)
# => A = [4.238254623316782e-49 1.1111111111111112; 0.9 1.62380556462724e-22]

println(B)
# => B = [1.0 4.282698599820089e-43; 1.4614250075436863e-22 1.0]



