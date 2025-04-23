# 1. (Fourier transform)
using FFTW

p_coeffs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
q_coeffs = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]


n = length(p_coeffs)
padded_length = nextpow(2, 2 * n - 1)  
p_padded = vcat(p_coeffs, zeros(padded_length - n))
q_padded = vcat(q_coeffs, zeros(padded_length - n))


fft_p = fft(p_padded)
fft_q = fft(q_padded)


fft_product = fft_p .* fft_q
product_coeffs = real(ifft(fft_product))
product_coeffs = product_coeffs[1:2*n-1]
@show product_coeffs
# => product_coeffs = [10.000000000000007, 28.999999999999996, 56.0, 89.99999999999999, 130.0, 175.0, 223.99999999999997, 276.0, 330.0, 385.0, 330.0, 276.0, 224.0, 175.0, 129.99999999999997, 90.0, 55.99999999999999, 29.000000000000007, 10.000000000000021]
# 2. (Householder reflection)


# 3. (BLAS)


# 4. (Optional - Back-substitution)

function back_substitution(U::AbstractMatrix, b::AbstractVector)
    n = size(U, 1)
    x = zeros(n)  

    x[n] = b[n] / U[n, n]


    for i = n-1:-1:1
        x[i] = (b[i] - dot(U[i, i+1:n], x[i+1:n])) / U[i, i]
    end

    return x
end

using Test
using LinearAlgebra
@testset "Back-substitution" begin
    U = [1 2 3;
     0 4 5;
     0 0 6]
    b = [7, 8, 9]

    x = back_substitution(U, b)

    @test x ≈ [2.25, 0.125, 1.5]
end




