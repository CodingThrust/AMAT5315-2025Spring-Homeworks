include("method.jl")
model = ["triangles","squares","diamonds"]

########################################################
# 2.1
########################################################
Random.seed!(42)
N0 = [12,12,13]
T = collect(0.1:0.1:2.0)
energy_gap_T = zeros(length(T),length(model))

for n = 1:3
    N = N0[n]
    for t = 1:length(T)
        @show n,t
        A = generate_topology_matrix(N,model[n])
        H = generate_hamiltonian(A,T[t])
        E,_ = eigsolve(H,normalize(rand(2^N)),10,:SR,KrylovKit.Lanczos())
        e2 = E[2]   
        flag = false
        for i in 2:10
            if abs(E[i]-E[1])>1e-4
                e2 = E[i]
                flag = true
                break
            end
        end
        if !flag
            error("No first excited state found")
        end
        energy_gap[t,n] = e2 - E[1]
    end
end

plot(T,energy_gap_T[:,1],label="triangles,sites=12",xlabel="Temperature",ylabel="Energy gap",title="Energy gap vs Temperature")
plot!(T,energy_gap_T[:,2],label="squares,sites=12")
plot!(T,energy_gap_T[:,3],label="diamonds,sites=13")


########################################################
# 2.2
########################################################
Random.seed!(42)
N1 = [collect(6:2:16),collect(6:2:16),collect(7:3:16)]
T1 = 0.1
energy_gap_N = [zeros(length(N1[n])) for n = 1:3]
for n = 1:3
    for i = 1:length(N1[n])
        N = N1[n][i]
        @show n,i
        A = generate_topology_matrix(N,model[n])
        H = generate_hamiltonian(A,T1)
        E,_ = eigsolve(H,normalize(rand(2^N)),5,:SR,KrylovKit.Lanczos())
        e2 = E[2]   
        flag = false
        for i in 2:10
            if abs(E[i]-E[1])>1e-4
                e2 = E[i]
                flag = true
                break
            end
        end
        if !flag
            error("No first excited state found")
        end
        energy_gap_N[n][i] = e2 - E[1]
    end
end



plot(N1[1],energy_gap_N[1],label="triangles",xlabel="Number of sites",ylabel="Energy gap",title="Energy gap vs Number of sites with T=0.1")
plot!(N1[2],energy_gap_N[2],label="squares")
plot!(N1[3],energy_gap_N[3],label="diamonds")



