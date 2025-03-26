# homework5
## 1. Fourier transform
```julia
using FFTW

# 定义多项式系数
p = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
q = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

n = length(p) + length(q) - 1

p_padded = [p; zeros(n - length(p))]
q_padded = [q; zeros(n - length(q))]

# 执行FFT
P = fft(p_padded)
Q = fft(q_padded)

# 频域相乘
R = P .* Q

result = real.(ifft(R))
coeffs = round.(Int, result)

println(coeffs)
```

```julia
[10, 29, 56, 90, 130, 175, 224, 276, 330, 385, 330, 276, 224, 175, 130, 90, 56, 29, 10] 
```
## 2. Householder reflection
For a m×n matrix A, the Flops of the Householder reflection algorithm is about: T1 = 2 m * n^2 - 2/3 * n^3,

So for a 1000×1000 matrix, the Flops is about 1.33e9.

the Flops of the Gram-Schmidt algorithm is about: T2 = 2 m * n^2

So for a 1000×1000 matrix, the Flops is about 2e9.

T1 < T2, so the Householder reflection algorithm is faster than the Gram-Schmidt algorithm.

## 3. BLAS
For origin function:
```julia
2.873 s (4406155 allocations: 7.58 GiB)
```
For improved function:
```julia
506.081 ms (2750 allocations: 3.92 MiB)
```
## 4. Back-substitution
main
```julia
function back_substitution(U, b)
    n = size(U, 1)
    x = zeros(n)
    for i in n:-1:1
        sum_val = 0.0
        for j in i+1:n
            sum_val += U[i, j] * x[j]
        end
        x[i] = (b[i] - sum_val) / U[i, i]
    end
    return x
end
```
test
```julia
using Test
include("question4.jl")

# 定义矩阵和向量
U = [1 2 3; 0 4 5; 0 0 6]
b = [7, 8, 9]

# 计算解
computed_x = back_substitution(U, b)

# 预期解
expected_x = [9/4, 1/8, 3/2]

# 测试结果是否匹配
@test computed_x ≈ expected_x atol=1e-10

println("测试通过！")
```