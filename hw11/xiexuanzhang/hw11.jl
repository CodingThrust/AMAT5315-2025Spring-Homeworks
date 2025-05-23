using TensorOperations

Random.seed!(42)

n = 3
m = 4

A = rand(n, n)
B = rand(n, n)
v = rand(n)
A1 = rand(n, m)
A2 = rand(m, n)
A3 = rand(n, m)
A4 = rand(m, n)
A5 = rand(n, n)

println("1. 矩阵-向量乘法:")
result_mv = einsum("ij,j->i", A, v)
println("结果维度: ", size(result_mv))
println("结果: \n", result_mv, "\n")

println("2. 矩阵迹:")
trace_value = einsum("ii", A)
println("迹值: ", trace_value)
println("验证(使用tr函数): ", tr(A), "\n")


println("3. 矩阵转置:")
transposed_A = einsum("ji", A)
println("转置结果: \n", transposed_A)
println("验证(使用transpose函数): \n", transpose(A), "\n")


println("4. 矩阵按行求和:")
sum_result = einsum("ij->j", A)
println("按行求和结果: ", sum_result)
println("验证(使用sum函数): ", sum(A, dims=1), "\n")


println("5. 五个矩阵连乘:")
product_result = einsum("ij,jk,kl,lm,mn->in", A1, A2, A3, A4, A5)
println("五矩阵连乘结果维度: ", size(product_result))
println("验证(分步乘法): ", A1 * A2 * A3 * A4 * A5, "\n")


println("6. 哈达玛积:")
hadamard_product = einsum("ij,ij->ij", A, B)
println("哈达玛积结果: \n", hadamard_product)
println("验证(使用点乘): \n", A .* B, "\n")

println("7. 张量收缩示例 (矩阵乘法):")
tensor_result = einsum("ik,kj->ij", A, B)
println("张量收缩结果: \n", tensor_result)
println("验证(使用*运算符): \n", A * B, "\n")


2.
using LinearAlgebra


function baum_welch(obs_seq, num_states, num_obs_symbols, max_iter = 100, tol = 1e-6)
   
    A = ones(num_states, num_states) ./ num_states
    B = ones(num_states, num_obs_symbols) ./ num_obs_symbols

    for iter = 1:max_iter
     
        α = Array{Float64, 2}(undef, num_states, length(obs_seq))
        α[:, 1] = B[:, obs_seq[1] + 1] / num_states
        for t = 2:length(obs_seq)
            for i = 1:num_states
                α[i, t] = sum(A[j, i] * α[j, t - 1] for j = 1:num_states) * B[i, obs_seq[t] + 1]
            end
        end

      
        β = Array{Float64, 2}(undef, num_states, length(obs_seq))
        β[:, end] = 1.0
        for t = length(obs_seq) - 1:-1:1
            for i = 1:num_states
                β[i, t] = sum(A[i, j] * B[j, obs_seq[t + 1] + 1] * β[j, t + 1] for j = 1:num_states)
            end
        end

     
        ξ = Array{Float64, 3}(undef, num_states, num_states, length(obs_seq) - 1)
        γ = Array{Float64, 2}(undef, num_states, length(obs_seq))
        for t = 1:length(obs_seq) - 1
            denom = sum(α[i, t] * β[i, t] for i = 1:num_states)
            for i = 1:num_states
                γ[i, t] = α[i, t] * β[i, t] / denom
                for j = 1:num_states
                    ξ[i, j, t] = α[i, t] * A[i, j] * B[j, obs_seq[t + 1] + 1] * β[j, t + 1] / denom
                end
            end
        end
        γ[:, end] = α[:, end] .* β[:, end] ./ sum(α[:, end] .* β[:, end])

 
        new_A = sum(ξ[:, :, t], dims = 3) ./ sum(γ[:, t], dims = 2)
        new_B = zeros(num_states, num_obs_symbols)
        for k = 1:num_obs_symbols
            obs_indices = findall(x -> x == k - 1, obs_seq)
            new_B[:, k] = sum(γ[:, obs_indices], dims = 2) ./ sum(γ, dims = 2)
        end

     
        if norm(new_A - A) < tol && norm(new_B - B) < tol
            break
        end
        A = new_A
        B = new_B
    end
    return A, B
end


obs_seq = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
num_states = 2  
num_obs_symbols = 2 

A, B = baum_welch(obs_seq, num_states, num_obs_symbols)
println("转移矩阵A: \n", A)
println("发射矩阵B: \n", B)
