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