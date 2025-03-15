using LinearAlgebra, FFTW, BenchmarkTools, Random

# 1. 

p = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
q = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

n = length(p)
m = length(q)
N = n + m - 1

p_padded = zeros(ComplexF64, N)
q_padded = zeros(ComplexF64, N)
p_padded[1:n] = p
q_padded[1:m] = q

fft_p = fft(p_padded)
fft_q = fft(q_padded)

fft_result = fft_p .* fft_q
result = real(ifft(fft_result))
result = round.(Int64, result)
#=
[10, 29, 56, 90, 130, 175, 224, 276, 330, 385, 330, 276, 224, 175, 130, 90, 56, 29, 10]
=#

########################
# 2.
#=
For a m×n matrix A, the Flops of the Householder reflection algorithm is about:
T1 = 2 m * n^2 - 2/3 * n^3

So for a 1000×1000 matrix, the Flops is about 1.33e9

For a m×n matrix A, the Flops of the Gram-Schmidt algorithm is about:
T2 = 2 m * n^2

So for a 1000×1000 matrix, the Flops is about 2e9

T1 < T2, so the Householder reflection algorithm is faster than the Gram-Schmidt algorithm.
=#

#######################
# 3.

# original

function lufact_pivot!(a::AbstractMatrix{T}) where T
	n = size(a, 1)
	@assert size(a, 2) == n "Matrix must be square"
	m = zeros(T, n, n)
	P = collect(1:n)

	# Loop over columns
	@inbounds for k ∈ 1:n-1
		# Find pivot (largest absolute value in current column)
		pivot_val = abs(a[k, k])
		pivot_idx = k
		for i ∈ k+1:n
			if abs(a[i, k]) > pivot_val
				pivot_val = abs(a[i, k])
				pivot_idx = i
			end
		end

		# Swap rows if necessary
		if pivot_idx != k
			# Swap rows k and pivot_idx of matrix A
			for col ∈ 1:n
				a[k, col], a[pivot_idx, col] = a[pivot_idx, col], a[k, col]
			end
			# Swap rows k and pivot_idx of matrix M
			for col ∈ 1:k-1
				m[k, col], m[pivot_idx, col] = m[pivot_idx, col], m[k, col]
			end
			P[k], P[pivot_idx] = P[pivot_idx], P[k]
		end

		# Skip if pivot is zero (matrix is singular)
		if iszero(a[k, k])
			continue
		end

		# Compute multipliers and update submatrix
		m[k, k] = one(T)
		for i ∈ k+1:n
			m[i, k] = a[i, k] / a[k, k]
			# Apply transformation directly (more efficient)
			for j ∈ k+1:n
				a[i, j] -= m[i, k] * a[k, j]
			end
			# Zero out elements below diagonal
			a[i, k] = zero(T)
		end
	end

	# Set the last diagonal element of L
	m[n, n] = one(T)

	return m, a, P
end


function my_lufact_pivot!(a::AbstractMatrix{T}) where T
	n = size(a, 1)
	@assert size(a, 2) == n "Matrix must be square"
	m = zeros(T, n, n)
	P = collect(1:n)

	# Loop over columns
	@inbounds for k ∈ 1:n-1
		# Find pivot (largest absolute value in current column)
		pivot_val = abs(a[k, k])
		pivot_idx = k
		for i ∈ k+1:n
			if abs(a[i, k]) > pivot_val
				pivot_val = abs(a[i, k])
				pivot_idx = i
			end
		end
		temp = Vector{T}(undef, n)

		# Swap rows if necessary
		if pivot_idx != k
			# Swap rows k and pivot_idx of matrix A

			BLAS.blascopy!(n, view(a, k, :), n, view(temp, :), 1)
			BLAS.blascopy!(n, view(a, pivot_idx, :), n, view(a, k, :), n)
			BLAS.blascopy!(n, view(temp, :), 1, view(a, pivot_idx, :), n)

			# Swap rows k and pivot_idx of matrix M

			BLAS.blascopy!(k - 1, view(m, k, :), n, view(temp, :), 1)
			BLAS.blascopy!(k - 1, view(m, pivot_idx, :), n, view(m, k, :), n)
			BLAS.blascopy!(k - 1, view(temp, :), 1, view(m, pivot_idx, :), n)

			P[k], P[pivot_idx] = P[pivot_idx], P[k]
		end

		# Skip if pivot is zero (matrix is singular)
		if iszero(a[k, k])
			continue
		end

		# Compute multipliers and update submatrix
		m[k, k] = one(T)
		for i=k+1:n
            m[i, k] = a[i, k] / a[k, k]
            # Apply transformation using BLAS axpy!
            BLAS.axpy!(-m[i, k], view(a, k, k+1:n), view(a, i, k+1:n))
            # Zero out elements below diagonal
            a[i,k] = zero(T)
        end
	end

	# Set the last diagonal element of L
	m[n, n] = one(T)

	return m, a, P
end

Random.seed!(3)
N = 100
A = randn(N, N)
A1 = copy(A)
@btime lufact_pivot!($A)
@btime my_lufact_pivot!($A1)

#=

Performance of original lufact_pivot! :
129.625 μs (5 allocations: 79.11 KiB)

Performance of my_lufact_pivot! : (Improved by using BLAS)
25.708 μs (203 allocations: 168.83 KiB)
=#




###############################
# 4.


function back_substitution(U::AbstractMatrix{T}, b::AbstractVector{T}) where T
    n = size(U, 1)
    @assert size(U, 2) == n "Matrix U must be square"
    @assert length(b) == n "Vector b must have length n"
    
    x = zeros(T, n)  
    
    for i = n:-1:1
        sum_known = zero(T)
        for j = i+1:n
            sum_known += U[i, j] * x[j]
        end
        
        x[i] = (b[i] - sum_known) / U[i, i]
    end
    
    return x
end

U = [1.0 2.0 3.0;
     0.0 4.0 5.0;
     0.0 0.0 6.0]

b = [7.0, 8.0, 9.0]

x = back_substitution(U, b)

println("Verify Ux = b:")
println(U * x ≈ b)  
# The result is true.

