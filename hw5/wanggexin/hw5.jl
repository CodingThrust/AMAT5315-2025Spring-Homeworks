############################################################
# 0·依赖
############################################################
using LinearAlgebra, FFTW, BenchmarkTools, BLAS
BLAS.set_num_threads(1)      # 基准时固定线程，真实应用可注释

############################################################
# 1·FFT 多项式卷积
############################################################
function polyconv_int(p::AbstractVector{<:Complex},
                      q::AbstractVector{<:Complex})
    n, m = length(p), length(q)
    N    = n + m - 1
    M    = nextfastfft(N)           # FFT 最优长度
    fft_p = fft!(ComplexF64[ p; zeros(M-n) ])
    fft_q = fft!(ComplexF64[ q; zeros(M-m) ])
    mul!.(fft_p, fft_p, fft_q)      # 就地逐元素乘
    res  = real.(ifft!(fft_p))[1:N] # 截取有效长度
    return round.(Int, res)
end

# quick demo
p = ComplexF64.(1:10)
q = ComplexF64.(10:-1:1)
@assert polyconv_int(p, q) == [10,29,56,90,130,175,224,276,330,385,330,276,224,175,130,90,56,29,10]

############################################################
# 2·高效行交换（视图 + BLAS.swap!）
############################################################
function swap_row!(A::AbstractMatrix, i::Integer, j::Integer)
    @assert 1 ≤ i ≤ size(A,1) && 1 ≤ j ≤ size(A,1) && i ≠ j "row id error"
    @views BLAS.swap!(view(A,i,:), view(A,j,:))
    return A
end

############################################################
# 3·部分主元 LU 分解 (返回 L,U,perm)
############################################################
function lufact_pivot!(A::AbstractMatrix{T}) where T<:BlasFloat
    n = size(A,1);  @assert size(A,2)==n "square only"
    L = Matrix{T}(I,n,n)
    perm = collect(1:n)

    for k in 1:n-1
        # 3.1 选主元
        pivot_idx = k - 1 + findmax(abs.(A[k:end,k]))[2]
        if pivot_idx ≠ k
            swap_row!(A, k, pivot_idx)
            swap_row!(L, k, pivot_idx)        # 只前 k‑1 列有效，但完整交换更简单
            perm[k], perm[pivot_idx] = perm[pivot_idx], perm[k]
        end
        a_kk = A[k,k];  iszero(a_kk) && continue

        # 3.2 计算倍数向量
        L[k+1:end,k] .= A[k+1:end,k] ./ a_kk
        A[k+1:end,k] .= 0                    # 显式清零

        # 3.3 rank‑1 更新：A[k+1:end,k+1:end] -= L*row
        BLAS.ger!(-one(T), L[k+1:end,k], A[k,k+1:end], view(A,k+1:end,k+1:end))
    end
    return L, UpperTriangular(A), perm
end

############################################################
# 4·后向替换
############################################################
function back_substitution(U::UpperTriangular{T}, b::AbstractVector{T}) where T
    n = length(b);  @assert size(U,1)==n "size mismatch"
    x = similar(b)
    @inbounds for i in n:-1:1
        s = b[i] - dot(U[i,i+1:end], x[i+1:end])
        x[i] = s / U[i,i]
    end
    return x
end

############################################################
# 5·简易验证 + Benchmark
############################################################
A  = randn(5,5); b = randn(5)
L,U,p = lufact_pivot!(copy(A))
x     = back_substitution(U, L\b[p])
@assert isapprox(A*x, b; atol=1e-10)

println("\nBenchmark on 100×100 random matrix:")
B = randn(100,100); v = randn(100)
@btime begin
    L,U,p = lufact_pivot!($B)
    back_substitution(U, L\$v[p])
end
