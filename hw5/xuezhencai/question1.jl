using FFTW

# 定义多项式系数
p = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
q = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

# 计算补零后的长度
n = length(p) + length(q) - 1

# 补零以扩展数组
p_padded = [p; zeros(n - length(p))]
q_padded = [q; zeros(n - length(q))]

# 执行FFT
P = fft(p_padded)
Q = fft(q_padded)

# 频域相乘
R = P .* Q

# 逆FFT并取实部，四舍五入为整数
result = real.(ifft(R))
coeffs = round.(Int, result)

# 输出结果
println("乘积多项式的系数为：")
println(coeffs)