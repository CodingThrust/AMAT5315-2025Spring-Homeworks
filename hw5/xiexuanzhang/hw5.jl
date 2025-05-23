1.
using FFTW

# Polynomial coefficients (ascending powers of x)
p_coeffs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]  # p(x) = 1 + 2x + ... + 10x^9
q_coeffs = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]    # q(x) = 10 + 9x + ... + x^9

# Calculate required FFT length (next power of 2 for efficiency)
m = length(p_coeffs)
n = length(q_coeffs)
dft_length = nextpow(2, m + n - 1)  # Optimal length for circular convolution

# Pad coefficients with zeros to match FFT length
p_padded = vcat(p_coeffs, zeros(dft_length - m))
q_padded = vcat(q_coeffs, zeros(dft_length - n))

# Compute Fast Fourier Transform of padded coefficients
fft_p = fft(p_padded)
fft_q = fft(q_padded)

# Element-wise multiplication in frequency domain
freq_product = fft_p .* fft_q

# Inverse FFT to get time-domain result and truncate to valid length
product_coeffs = real.(ifft(freq_product))[1:m+n-1]

# Round to nearest integer (avoids floating point precision errors)
integer_coeffs = round.(Int, product_coeffs)

# Display results
println("Polynomial product coefficients:")
@show integer_coeffs
2.
# Define the number of rows and columns of the matrix
m = 1000
n = 1000

# Function to count the Flops for Householder reflection algorithm
function count_flops_householder()
    # The formula for Flops of Householder reflection algorithm for an m x n matrix
    # T1 = 2 * m * n^2 - 2/3 * n^3
    # This formula is derived from the operations involved in the Householder reflection process.
    # Each step of the algorithm has specific arithmetic operations that contribute to this formula.
    return 2 * m * n^2 - 2 / 3 * n^3
end

# Function to count the Flops for Gram - Schmidt algorithm
function count_flops_gram_schmidt()
    # The formula for Flops of Gram - Schmidt algorithm for an m x n matrix
    # T2 = 2 * m * n^2
    # It comes from the inner - product calculations and vector - subtraction operations in the Gram - Schmidt process.
    return 2 * m * n^2
end

# Calculate the Flops for Householder reflection algorithm
flops_householder = count_flops_householder()
println("The number of Flops for Householder reflection algorithm for a 1000x1000 matrix is approximately: ", flops_householder)

# Calculate the Flops for Gram - Schmidt algorithm
flops_gram_schmidt = count_flops_gram_schmidt()
println("The number of Flops for Gram - Schmidt algorithm for a 1000x1000 matrix is approximately: ", flops_gram_schmidt)

# Compare the Flops of the two algorithms
if flops_householder < flops_gram_schmidt
    println("The Householder reflection algorithm is faster than the Gram - Schmidt algorithm.")
else
    println("The Gram - Schmidt algorithm is faster than the Householder reflection algorithm.")
end

3.
using LinearAlgebra
using BenchmarkTools

# Optimized LU factorization with pivoting using BLAS (faster row swapping and fewer operations)
function lufact_pivot_blas_optimized!(a::AbstractMatrix{T}) where T
    n = size(a, 1)
    @assert size(a, 2) == n "Matrix must be square"
    m = similar(a, T, n, n)  # Reuse matrix type for better memory alignment
    P = collect(1:n)
    temp = Vector{T}(undef, n)  # Temporary vector for row swapping

    @inbounds for k ∈ 1:n-1
        # Find pivot (using view for better performance)
        col = @view a[k:n, k]  # View of current column from row k to n
        pivot_idx = k + argmax(abs.(col)) - 1  # Convert to 1-based index
        pivot_val = abs(col[pivot_idx - k + 1])  # Get pivot value

        if pivot_idx != k
            # Swap rows using BLAS (1 call instead of 3 for better cache utilization)
            BLAS.axpy!(1.0, view(a, k, :), view(temp, :))        # temp = row k
            BLAS.axpy!(1.0, view(a, pivot_idx, :), view(a, k, :))  # row k = row pivot_idx
            BLAS.axpy!(1.0, view(temp, :), view(a, pivot_idx, :))  # row pivot_idx = temp

            # Swap rows in matrix m (only for columns < k)
            if k > 1
                BLAS.axpy!(1.0, view(m, k, 1:k-1), view(temp, 1:k-1))        # temp = m row k (first k-1 elements)
                BLAS.axpy!(1.0, view(m, pivot_idx, 1:k-1), view(m, k, 1:k-1))  # m row k = m row pivot_idx
                BLAS.axpy!(1.0, view(temp, 1:k-1), view(m, pivot_idx, 1:k-1))  # m row pivot_idx = temp
            end
            P[k], P[pivot_idx] = P[pivot_idx], P[k]
        end

        # Skip singular pivot
        if iszero(a[k, k])
            continue
        end

        # Compute multipliers and update using BLAS.axpy! (vectorized operations)
        m[k, k] = one(T)
        @inbounds for i ∈ k+1:n
            m[i, k] = a[i, k] / a[k, k]
            BLAS.axpy!(-m[i, k], @view(a[k, k+1:n]), @view(a[i, k+1:n]))
            a[i, k] = zero(T)  # Explicitly zero for clarity (optional in practice)
        end
    end
    m[n, n] = one(T)
    return m, a, P
end

# Original function for comparison
function lufact_pivot_original!(a::AbstractMatrix{T}) where T
    n = size(a, 1)
    @assert size(a, 2) == n
    m = zeros(T, n, n)
    P = collect(1:n)
    for k ∈ 1:n-1
        pivot_idx = k + argmax(abs.(@view a[k:n, k])) - 1
        if pivot_idx != k
            a[[k, pivot_idx], :] = a[[pivot_idx, k], :]
            m[[k, pivot_idx], 1:k-1] = m[[pivot_idx, k], 1:k-1]
            P[k], P[pivot_idx] = P[pivot_idx], P[k]
        end
        if iszero(a[k, k]) continue end
        m[k, k] = one(T)
        for i ∈ k+1:n
            m[i, k] = a[i, k]/a[k, k]
            a[i, k+1:n] -= m[i, k] * a[k, k+1:n]
            a[i, k] = zero(T)
        end
    end
    m[n, n] = one(T)
    return m, a, P
end

# Benchmark setup
n = 1000
A = randn(n, n)
A_original = copy(A)
A_optimized = copy(A)

# Timing
println("Original function (Julia loops):")
@btime lufact_pivot_original!($A_original)

println("\nOptimized BLAS function:")
@btime lufact_pivot_blas_optimized!($A_optimized)

4.
using Test
using LinearAlgebra

function back_substitution(U::AbstractMatrix, b::AbstractVector)
    n = size(U, 1)
    x = zeros(n)
    x[n] = b[n] / U[n, n]
    for i = n - 1:-1:1
        x[i] = (b[i] - dot(U[i, i + 1:n], x[i + 1:n])) / U[i, i]
    end
    return x
end

@testset "Back-substitution" begin
    U = [1 2 3;
         0 4 5;
         0 0 6]
    b = [7, 8, 9]
    x = back_substitution(U, b)
    @test x ≈ [2.25, 0.125, 1.5]
end