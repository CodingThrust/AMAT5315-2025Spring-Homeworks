using Pkg
Pkg.activate("./hw5/huanhaizhou")

# Problem 1

using FFTW

p = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
q = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

n = length(p)
m = length(q)
N = n + m - 1

p_padded = [p; zeros(N - n)]
q_padded = [q; zeros(N - m)]

fft_p = fft(p_padded)
fft_q = fft(q_padded)

fft_product = fft_p .* fft_q
result = real(ifft(fft_product))
result = round.(Int64, result)
@show result # result = [10, 29, 56, 90, 130, 175, 224, 276, 330, 385, 330, 276, 224, 175, 130, 90, 56, 29, 10]


# Problem 3

using LinearAlgebra, BenchmarkTools

function lufact_pivot!(a::AbstractMatrix{T}) where T
	n = size(a, 1)
	@assert size(a, 2) == n "Matrix must be square"
	m = zeros(T, n, n)
	p = collect(1:n)

	@inbounds for k ∈ 1:n-1
		pivot_val = abs(a[k, k])
		pivot_idx = k
		for i ∈ k+1:n
			if abs(a[i, k]) > pivot_val
				pivot_val = abs(a[i, k])
				pivot_idx = i
			end
		end

		if pivot_idx != k
			for j ∈ 1:n
				a[k, j], a[pivot_idx, j] = a[pivot_idx, j], a[k, j]
			end
			for j ∈ 1:k-1
				m[k, j], m[pivot_idx, j] = m[pivot_idx, j], m[k, j]
			end
			p[k], p[pivot_idx] = p[pivot_idx], p[k]
		end

		if iszero(a[k, k])
			continue
		end

		m[k, k] = one(T)
		for i ∈ k+1:n
			m[i, k] = a[i, k] / a[k, k]
			for j ∈ k+1:n
				a[i, j] -= m[i, k] * a[k, j]
			end
			a[i, k] = zero(T)
		end
	end

	m[n, n] = one(T)

	return m, a, p
end

function lufact_pivot_blas!(a::AbstractMatrix{T}) where T
	n = size(a, 1)
	@assert size(a, 2) == n "Matrix must be square"
	m = zeros(T, n, n)
	p = collect(1:n)
	temp = zeros(T, n)

	@inbounds for k ∈ 1:n-1
		pivot_val = abs(a[k, k])
		pivot_idx = k
		for i ∈ k+1:n
			if abs(a[i, k]) > pivot_val
				pivot_val = abs(a[i, k])
				pivot_idx = i
			end
		end

		if pivot_idx != k
			@views BLAS.blascopy!(n, a[k, :], 1, temp, 1)
			@views BLAS.blascopy!(n, a[pivot_idx, :], 1, a[k, :], 1)
			@views BLAS.blascopy!(n, temp, 1, a[pivot_idx, :], 1)
			
			if k > 1
				@views BLAS.blascopy!(k-1, m[k, 1:k-1], 1, temp[1:k-1], 1)
				@views BLAS.blascopy!(k-1, m[pivot_idx, 1:k-1], 1, m[k, 1:k-1], 1)
				@views BLAS.blascopy!(k-1, temp[1:k-1], 1, m[pivot_idx, 1:k-1], 1)
			end
			
			p[k], p[pivot_idx] = p[pivot_idx], p[k]
		end

		if iszero(a[k, k])
			continue
		end

		m[k, k] = one(T)
		for i ∈ k+1:n
			m[i, k] = a[i, k] / a[k, k]
			@views BLAS.axpy!(-m[i, k], a[k, k+1:n], a[i, k+1:n])
			a[i, k] = zero(T)
		end
	end

	m[n, n] = one(T)

	return m, a, p
end

function benchmark_fact(n)
    A₁ = randn(n,n)
    A₂ = copy(A₁)
    println("—— n = $n ——")
    b1 = @benchmark lufact_pivot!($A₁)
    display(b1)
    
    b2 = @benchmark lufact_pivot_blas!($A₂)
    display(b2)
    
    t1 = minimum(b1.times)
    t2 = minimum(b2.times)
    speedup = t1/t2
    
    mem1 = b1.memory
    mem2 = b2.memory
    mem_red = mem1 > 0 ? (mem1 - mem2) / mem1 * 100 : 0
    
    println("\nSpeedup: $(round(speedup, digits=2))x")
    println("Memory reduction: $(round(mem_red, digits=2))%")
    println()
end

for n in (200, 500, 1000)
    benchmark_fact(n)
end


# Problem 4

using Test

function back_substitution(U::AbstractMatrix, b::AbstractVector)
    n = size(U, 1)
    x = zeros(n)
    x[n] = b[n] / U[n, n]

    for i = n-1:-1:1
        x[i] = (b[i] - dot(U[i, i+1:n], x[i+1:n])) / U[i, i]
    end

    return x
end

@testset "HW5 Problem 4: Back-substitution" begin
    U = [1 2 3;
        0 4 5;
        0 0 6]
    b = [7, 8, 9]

    x = back_substitution(U, b)

    @test U * x ≈ b
end
