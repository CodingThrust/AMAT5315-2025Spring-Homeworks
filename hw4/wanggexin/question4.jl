using LinearAlgebra

N = 21
C = 3.0
m_e = 1.0
m_o = 2.0

masses = [isodd(i) ? m_o : m_e for i in 1:N]
M = diagm(masses)

K = Tridiagonal(
    -C * ones(N-1),  
     2C * ones(N),   
    -C * ones(N-1)   
)

eigenvals = eigen(K, M).values

frequencies = sqrt.(real(eigenvals)) ./ (2π)

sorted_freq = sort(frequencies)

println("first 10 (Hz)：")
for i in 1:10
    println("ωₖ = ", round(sorted_freq[i], digits=4))
end