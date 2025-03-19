using LinearAlgebra, BenchmarkTools, FFTW

p = ComplexF64[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
q = ComplexF64[10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

n = length(p)
m = length(q)
N = n + m - 1

fft_p = fft(vcat(p, zeros(ComplexF64, N-n)))
fft_q = fft(vcat(q, zeros(ComplexF64, N-m)))

fft_result = fft_p .* fft_q
result = real(ifft(fft_result))
result = round.(Int64, result)

########################

function swap_row!(A::AbstractMatrix, i::Int, j::Int)
    n=size(A, 1)
    @assert 1 <= i <= n "Row index i out of bounds"
    @assert 1 <= j <= n "Row index j out of bounds"
    @assert i != j "Row indices must be different"
    @assert size(A, 2) == n "Matrix must be square"
    temp = zeros(eltype(A), n) 

    BLAS.blascopy!(n, view(A, i, :), n, temp, 1)

    BLAS.blascopy!(n, view(A, j, :), n, view(A, i, :), n)

    BLAS.blascopy!(n, temp, 1, view(A, j, :), n)
    
    return A
end

function lufact_pivot!(a::AbstractMatrix{T}) where T
    n = size(a, 1)
    @assert size(a, 2) == n "Matrix must be square"
    m = zeros(T, n, n)
    P = collect(1:n)
    
    # Loop over columns
    @inbounds for k=1:n-1
        # Find pivot (largest absolute value in current column)
        pivot_val = abs(a[k,k])
        pivot_idx = k
        for i=k+1:n
            if abs(a[i,k]) > pivot_val
                pivot_val = abs(a[i,k])
                pivot_idx = i
            end
        end
        
        # Swap rows if necessary
        if pivot_idx != k
            # Swap rows k and pivot_idx of matrix A
            for col = 1:n
                a[k, col], a[pivot_idx, col] = a[pivot_idx, col], a[k, col]
            end
            # Swap rows k and pivot_idx of matrix M
            for col = 1:k-1
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
        for i=k+1:n
            m[i, k] = a[i, k] / a[k, k]
            # Apply transformation directly (more efficient)
            for j=k+1:n
                a[i,j] -= m[i,k] * a[k,j]
            end
            # Zero out elements below diagonal
            a[i,k] = zero(T)
        end
    end
    
    # Set the last diagonal element of L
    m[n, n] = one(T)
    
    return m, a, P
end

function mylufact_pivot!(a::AbstractMatrix{T}) where T
    n = size(a, 1)
    @assert size(a, 2) == n "Matrix must be square"
    m = zeros(T, n, n)
    P = collect(1:n)
    
    # Loop over columns
    @inbounds for k=1:n-1
        # Find pivot (largest absolute value in current column)
        pivot_val = abs(a[k,k])
        pivot_idx = k
        for i=k+1:n
            if abs(a[i,k]) > pivot_val
                pivot_val = abs(a[i,k])
                pivot_idx = i
            end
        end
        # Swap rows if necessary
        if pivot_idx != k
            # Swap rows k and pivot_idx of matrix A
            swap_row!(a, k, pivot_idx)
            # Swap rows k and pivot_idx of matrix L
            swap_row!(m, k, pivot_idx)
            # Swap rows k and pivot_idx of permutation matrix P
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
            # Apply transformation directly (more efficient) 
            # BLAS.blascopy!(n-k, BLAS.axpy!(-m[i,k], view(a,k, k+1:n), zeros(T, n-k)), 1, view(a, i, k), n)
            BLAS.axpy!(-m[i, k], view(a, k, k+1:n), view(a, i, k+1:n))
            # Zero out elements below diagonal
            a[i,k] = zero(T)
        end
    end
    
    # Set the last diagonal element of L
    m[n, n] = one(T)
    
    return m, a, P
end


#=
Performance of original lufact_pivot! :
203.726 μs (6 allocations: 79.14 KiB) (Intel 8458P)
128.084 μs (6 allocations: 157.25 KiB) (mba M3)
Performance of mylufact_pivot!
43.314 μs (6 allocations: 79.14 KiB) (Intel 8458P)
206.916 μs (194 allocations: 321.75 KiB) (mba M3) ???
=#

function back_substitution(U::AbstractMatrix{T}, b::AbstractVector{T}) where T
    n = length(b)
    @assert size(U) == (n, n) "Matrix U must be square, with size equal to length of b"

    x = similar(b)  

    for i in reverse(1:n)
        if iszero(U[i, i])
            error("The upper triangular matrix is singular")
        end
        s=b[i]
        for j in i+1:n
            s -= U[i, j] * x[j]
        end
        x[i] = s / U[i, i]
    end

    return x
end

