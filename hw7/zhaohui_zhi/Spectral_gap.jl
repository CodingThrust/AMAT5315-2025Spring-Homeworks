include("./Lattice.jl")
using Pkg
Pkg.activate("./hw7/zhaohui_zhi")
Pkg.instantiate()
using Graphs, ProblemReductions
using SparseArrays
using Arpack
using Plots
using JLD

function transition_matrix(sg::SpinGlass, beta::T) where T
    N = num_variables(sg)
    P = zeros(T, 2^N, 2^N)  # P[i, j] = probability of transitioning from j to i
    readbit(cfg, i::Int) = (cfg >> (i - 1)) & 1  # read the i-th bit of cfg
    int2cfg(cfg::Int) = [readbit(cfg, i) for i in 1:N]
    for j in 1:2^N
        for i in 1:2^N
            if count_ones((i-1) ⊻ (j-1)) == 1  # Hamming distance is 1
                P[i, j] = 1/N * min(one(T), exp(-beta * (energy(sg, int2cfg(i-1)) - energy(sg, int2cfg(j-1)))))
            end
        end
        P[j, j] = 1 - sum(P[:, j])  # rejected transitions
    end
    return P
end

function transition_matrix_sparse(sg::SpinGlass, beta::T) where T <: Real
    N = num_variables(sg)
    total_states = 2^N
    I = Int[]   # 行索引
    J = Int[]   # 列索引
    V = T[]     # 非零值
    
    # 预分配内存以提高效率
    sizehint!(I, total_states * (N + 1))
    sizehint!(J, total_states * (N + 1))
    sizehint!(V, total_states * (N + 1))
    
    # 辅助函数：整数转自旋配置
    readbit(cfg, i::Int) = (cfg >> (i - 1)) & 1
    int2cfg(cfg::Int) = [readbit(cfg, i) for i in 1:N]
    
    # 遍历所有状态 j（列索引）
    for j_col in 1:total_states
        state_j = int2cfg(j_col - 1)  # 转换为自旋配置
        sum_prob = zero(T)  # 累积转移概率
        
        # 遍历所有可能的单自旋翻转（生成行索引 i）
        for k in 1:N
            # 翻转第 k 个自旋的二进制位
            i_row = (j_col - 1) ⊻ (1 << (k - 1)) + 1  # +1 转换为 1-based 索引
            state_i = int2cfg(i_row - 1)
            
            # 计算能量差和转移概率
            ΔE = energy(sg, state_i) - energy(sg, state_j)
            prob = min(one(T), exp(-beta * ΔE)) / N
            
            # 收集非零元素
            push!(I, i_row)
            push!(J, j_col)
            push!(V, prob)
            sum_prob += prob
        end
        
        # 处理对角线元素（未发生翻转的概率）
        diag_prob = one(T) - sum_prob
        push!(I, j_col)
        push!(J, j_col)
        push!(V, diag_prob)
    end
    
    # 构建稀疏矩阵
    P = sparse(I, J, V, total_states, total_states)
    return P
end


function spectral_gap(P)
    eigenvalues, _ = eigs(P, nev=3, which=:LR)
    return 1.0 - real(eigenvalues[2])
end

#====#
graphtri=triangles(9,2)
graphsq=squares(9,2)
graphdi=diamonds(6,3)

sgtri=SpinGlass(graphtri, ones(Int, ne(graphtri)), zeros(Int, nv(graphtri)))
sgsq=SpinGlass(graphsq, ones(Int, ne(graphsq)), zeros(Int, nv(graphsq)))
sgdi=SpinGlass(graphdi, ones(Int, ne(graphdi)), zeros(Int, nv(graphdi)))

templis=collect(0.1:0.4:2.0)
gaplistri=similar(templis)
gaplissq=similar(templis)
gaplisdi=similar(templis)
for (idx,i) in enumerate(templis)
    Ptri=transition_matrix_sparse(sgtri,i)
    Psq=transition_matrix_sparse(sgsq,i)
    Pdi=transition_matrix_sparse(sgdi,i)
    println("beta=",i)
    gaptri=spectral_gap(Ptri)
    gapsq=spectral_gap(Psq)
    gapdi=spectral_gap(Pdi)
    println("triangles spectral gap=",gaptri)
    println("squares spectral gap=",gapsq)
    gaplistri[idx]=gaptri
    gaplissq[idx]=gapsq
    gaplisdi[idx]=gapdi
end

save("gapbeta.jld", "gaptri", gaplistri, "gapsq", gaplissq, "gapdi", gaplisdi)
fig=plot(templis, gaplistri, label="triangles", xlabel="beta", ylabel="Spectral gap", legend=:topleft)
plot!(templis, gaplissq, label="squares")
plot!(templis, gaplisdi, label="diamonds")
savefig(fig, "./spectral_gap_vs_beta.pdf")
#====#

Nlis=collect(2:6)
beta=0.1
gapNlistri=zeros(length(Nlis))
gapNlissq=zeros(length(Nlis))
gapNlisdi=zeros(length(Nlis))
for (idx, i) in enumerate(Nlis)
    graphtri=triangles(i,2)
    graphsq=squares(i,2)
    graphdi=diamonds(i,3)

    sgtri=SpinGlass(graphtri, ones(Int, ne(graphtri)), zeros(Int, nv(graphtri)))
    sgsq=SpinGlass(graphsq, ones(Int, ne(graphsq)), zeros(Int, nv(graphsq)))
    sgdi=SpinGlass(graphdi, ones(Int, ne(graphdi)), zeros(Int, nv(graphdi)))

    Ptri=transition_matrix_sparse(sgtri,beta)
    Psq=transition_matrix_sparse(sgsq,beta)
    Pdi=transition_matrix_sparse(sgdi,beta)

    println("N=",i)
    gaptri=spectral_gap(Ptri)
    gapsq=spectral_gap(Psq)
    gapdi=spectral_gap(Pdi)
    println("triangles spectral gap=",gaptri)
    println("squares spectral gap=",gapsq)
    println("diamonds spectral gap=",gapdi)
    gapNlistri[idx]=gaptri
    gapNlissq[idx]=gapsq
    gapNlisdi[idx]=gapdi
end

save("gapNlis.jld", "gaptri", gapNlistri, "gapsq", gapNlissq, "gapdi", gapNlisdi)
fig=plot(Nlis, gapNlistri, label="triangles", xlabel="N", ylabel="Spectral gap", legend=:topleft)
plot!(Nlis, gapNlissq, label="squares")
plot!(Nlis, gapNlisdi, label="diamonds")
savefig(fig, "./spectral_gap_vs_N.pdf")
