include("method.jl")
S = Float64
########################################################
# 2.1
########################################################
N0 = [18, 18, 19]
T = S.(collect(0.1:0.3:2.0))
function generate_p1(N0::Vector{Int64}, T::Vector{S}) where S
    Random.seed!(42)
    model = ["triangles", "squares", "diamonds"]
    energy_gap = zeros(S, length(T), length(model))
    eignum = 10

    for n ∈ 1:3
        N = N0[n]
        for t ∈ 1:length(T)
            @show (n, t)
            A = generate_topology_matrix(N, model[n])
            H = generate_hamiltonian(A, T[t])
            E, _ = eigsolve(H, normalize(rand(S, 2^N)), eignum, :LR, KrylovKit.Arnoldi())
            energy_gap[t, n] = abs(real(S(1.0) - E[2]))
        end
    end
    return energy_gap
end
energy_gap = generate_p1(N0, T)
plot(T, energy_gap[:, 1], label = "triangles,sites=$(N0[1])", xlabel = "Temperature", ylabel = "Energy gap", title = "Energy gap vs Temperature", yscale = :log10)
plot!(T, energy_gap[:, 2], label = "squares,sites=$(N0[2])")
plot!(T, energy_gap[:, 3], label = "diamonds,sites=$(N0[3])")


########################################################
# 2.2
########################################################
N = [collect(6:2:18), collect(6:2:18), collect(7:3:19)]
T = 0.1
function generate_p2(Nvec::Vector{Vector{Int64}},T::S) where S
    Random.seed!(42)
    model = ["triangles", "squares", "diamonds"]
    energy_gap_N = [zeros(length(Nvec[n])) for n ∈ 1:3]
    eignum = 10
    for n ∈ 1:3
        for i ∈ 1:length(N[n])
            @show (n, i)
            N = Nvec[n][i]
            A = generate_topology_matrix(N, model[n])
            H = generate_hamiltonian(A, T)
            E, _ = eigsolve(H, normalize(rand(2^N)), eignum, :LM, KrylovKit.Arnoldi())
            energy_gap_N[n][i] = abs(real(S(1.0) - E[2]))
        end
    end
    return energy_gap_N
end
energy_gap_N = generate_p2(N, T)
plot(N[1], energy_gap_N[1], label = "triangles", xlabel = "Number of sites", ylabel = "Energy gap", title = "Energy gap vs Number of sites with T=0.1")
plot!(N[2], energy_gap_N[2], label = "squares")
plot!(N[3], energy_gap_N[3], label = "diamonds")


