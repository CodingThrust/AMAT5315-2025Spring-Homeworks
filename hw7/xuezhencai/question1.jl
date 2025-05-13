using Graphs, ProblemReductions, Random

function fullerene()
    th = (1 + sqrt(5)) / 2
    res = NTuple{3,Float64}[]
    for (x, y, z) in ((0.0, 1.0, 3th), (1.0, 2 + th, 2th), (th, 2.0, 2th + 1.0))
        for (a, b, c) in ((x,y,z), (y,z,x), (z,x,y))
            for loc in ((a,b,c), (a,b,-c), (a,-b,c), (a,-b,-c),
                        (-a,b,c), (-a,b,-c), (-a,-b,c), (-a,-b,-c))
                if loc ∉ res
                    push!(res, loc)
                end
            end
        end
    end
    return res
end

fullerene_graph = UnitDiskGraph(fullerene(), sqrt(5))
node_list = vertices(fullerene_graph)
edge_list = collect(edges(fullerene_graph))


max_iters = 10000
T_init = 5.0
T_min = 1e-4
cooling = 0.995

spins = Dict(n => rand(Bool) ? 1 : -1 for n in node_list)

function energy(spins)
    return sum(spins[src(e)] * spins[dst(e)] for e in edge_list)
end


function simulated_annealing()
    T = T_init
    best_spins = deepcopy(spins)
    best_energy = energy(spins)
    current_energy = best_energy

    for iter in 1:max_iters
        node = rand(node_list)
        spins[node] *= -1
        new_energy = energy(spins)
        ΔE = new_energy - current_energy

        if ΔE < 0 || rand() < exp(-ΔE / T)
            current_energy = new_energy
            if current_energy < best_energy
                best_energy = current_energy
                best_spins = deepcopy(spins)
            end
        else
            spins[node] *= -1
        end

        T *= cooling
        if T < T_min
            break
        end
    end

    return best_energy, best_spins
end

best_E, config = simulated_annealing()
println("Ground state energy ≈ ", best_E)
