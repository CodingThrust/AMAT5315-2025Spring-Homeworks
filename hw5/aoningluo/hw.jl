1.
using FFTW
P = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
Q = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
n = max(length(P), length(Q))
N = 2 * n - 1
P_padded = vcat(P, zeros(Complex{Float64}, N - length(P)))
Q_padded = vcat(Q, zeros(Complex{Float64}, N - length(Q)))
P_fft = fft(P_padded)
Q_fft = fft(Q_padded)
R_fft = P_fft .* Q_fft
R = ifft(R_fft)
R_coefficients = round.(real(R))
println("Resulting polynomial coefficients: ", R_coefficients)

2.
function householder_flops(n)
    flops = 0
    for k in 1:n
        flops += 2 * n
        flops += 2 * (n - k) * n
    end
    return flops
end
function gram_schmidt_flops(m, n)
    flops = 0
    for j in 1:n
        flops += 2 * j
        flops += 2 * m * j
    end
    return flops
end
m, n = 1000, 1000
householder_ops = householder_flops(n)
gram_schmidt_ops = gram_schmidt_flops(m, n)
println("Householder Reflection FLOPs: ", householder_ops)
println("Gram-Schmidt FLOPs: ", gram_schmidt_ops)


using Random
using LinearAlgebra

function householder_reflection(A)
    m, n = size(A)
    flops = 0 

    for k in 1:n
        x = A[k:m, k]
        e = zeros(length(x))
        e[1] = norm(x) * sign(x[1])
        v = x - e
        
        v_norm = norm(v)
        flops += 2 * (m - k + 1)

        A[k:m, k:n] -= 2 * (v * (v' * A[k:m, k:n]))
        flops += 2 * (m - k + 1) * (n - k) + 3 * (m - k + 1)
    end

    return A, flops
end

A = rand(1000, 1000)

_, householder_flops = householder_reflection(copy(A))

_, gram_schmidt_flops = gram_schmidt(copy(A))

println("Householder reflection FLOPS: ", householder_flops)
println("Gram-Schmidt FLOPS: ", gram_schmidt_flops)

3.
using LinearAlgebra
using BenchmarkTools
using BLAS

function lufact_pivot!(A)
    m, n = size(A)
    for k in 1:min(m, n)
        pivot = argmax(abs.(A[k:m, k])) + k - 1
        A[[k, pivot], :] .= A[[pivot, k], :]
        for j in k+1:m
            A[j, k] /= A[k, k]
            A[j, k+1:n] .-= A[j, k] * A[k, k+1:n]
        end
    end
    return A
end

function lufact_pivot_blas!(A)
    m, n = size(A)
    for k in 1:min(m, n)
        pivot = argmax(abs.(A[k:m, k])) + k - 1
        A[[k, pivot], :] .= A[[pivot, k], :]
        for j in k+1:m
            A[j, k] /= A[k, k]
            BLAS.axpy!(n-k, -A[j, k], A[k, k+1:n], 1, A[j, k+1:n], 1)
        end
    end
    return A
end

A = rand(1000, 1000)

A_original = copy(A)

@btime lufact_pivot!($A_original)
A_blas = copy(A)
@btime lufact_pivot_blas!($A_blas)

4.
function back_substitution(U, b)
    n = length(b)
    x = zeros(n)
    
    for i in n:-1:1
        sum = 0.0
        for j in i+1:n
            sum += U[i, j] * x[j]
        end
        x[i] = (b[i] - sum) / U[i, i]
    end
    
    return x
end

U = [1 2 3; 0 4 5; 0 0 6]
b = [7, 8, 9]

x = back_substitution(U, b)

println("Solution x: ", x)

println("Verification U * x: ", U * x)
println("Original b: ", b)