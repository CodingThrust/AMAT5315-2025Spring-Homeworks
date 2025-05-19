1.
```julia
using FFTW

p = collect(1:10);
q = collect(10:-1:1);

n = length(p) + length(q) - 1;

p_pad = ComplexF64.(vcat(p, zeros(n - length(p))));
q_pad = ComplexF64.(vcat(q, zeros(n - length(q))));

P = fft(p_pad);
Q = fft(q_pad);
R = P .* Q;
r = real.(ifft(R));

result = round.(r[1:n]; digits=6);
println(result)
[10.0, 29.0, 56.0, 90.0, 130.0, 175.0, 224.0, 276.0, 330.0, 385.0, 330.0, 276.0, 224.0, 175.0, 130.0, 90.0, 56.0, 29.0, 10.0]

```

2.

Householder Reflection Flops: $\frac{4}{3}n^2(3m - n) = \frac{4}{3} \cdot 1000^2 \cdot 2000 = 2.67 \times 10^9$

Classical Gram-Schmidt Flops: $2mn(n+1) = 2 \cdot 1000 \cdot 1000 \cdot 1001 = 2.002 \times 10^9$

Therefore, the Householder reflection algorithm is faster than the Gram-Schmidt algorithm under this condition.

3.
```julia
using LinearAlgebra, BenchmarkTools

function lufact_pivot_original!(A::StridedMatrix{T}) where T
    n = size(A,1)
    for k in 1:n-1
        jp = k + findmax(abs.(A[k:end,k]))[2] - 1
        A[k, :], A[jp, :] = A[jp, :], A[k, :]     

        for i in k+1:n
            α = A[i,k] / A[k,k]
            A[i,k] = α
            for j in k+1:n
                A[i,j] -= α * A[k,j]
            end
        end
    end
    return A
end


function lufact_pivot_blas!(A::StridedMatrix{T}) where T
    n = size(A,1)
    for k in 1:n-1
        jp = k + findmax(abs.(A[k:end,k]))[2] - 1
        if jp != k
            tmp = similar(A, 1, n)
            BLAS.copy!(view(tmp,1,:), view(A,k,:))   
            BLAS.copy!(view(A,k,:), view(A,jp,:))   
            BLAS.copy!(view(A,jp,:), view(tmp,1,:))  
        end

        Akk = A[k,k]
        for i in k+1:n
            α = A[i,k] / Akk
            A[i,k] = α
            BLAS.axpy!(-α, view(A,k,k+1:n), view(A,i,k+1:n)) 
        end
    end
    return A
end


function benchmark_fact(n)
    A₁ = randn(n,n)
    A₂ = copy(A₁)
    println("—— n = $n ——")
    println("original:")
    @btime lufact_pivot_original!($A₁)
    println("blas:")
    @btime lufact_pivot_blas!($A₂)
    println()
end

for n in (200, 500, 1000)
    benchmark_fact(n)
end

—— n = 200 ——
original:
  2.056 ms (1592 allocations: 995.44 KiB)
blas:
  189.600 μs (796 allocations: 348.69 KiB)

—— n = 500 ——
original:
  38.651 ms (5488 allocations: 5.90 MiB)
blas:
  35.485 ms (2494 allocations: 2.00 MiB)

—— n = 1000 ——
original:
  652.441 ms (11488 allocations: 23.18 MiB)
blas:
  521.838 ms (5494 allocations: 7.82 MiB)
```
