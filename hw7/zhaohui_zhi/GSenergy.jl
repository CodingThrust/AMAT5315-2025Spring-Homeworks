using Pkg
Pkg.activate("./hw7/zhaohui_zhi")
Pkg.instantiate()
using Graphs, ProblemReductions
using GraphPlot
using OMEinsum, TropicalNumbers

function fullerene()  # construct the fullerene graph in 3D space
    th = (1+sqrt(5))/2
    res = NTuple{3,Float64}[]
    for (x, y, z) in ((0.0, 1.0, 3th), (1.0, 2 + th, 2th), (th, 2.0, 2th + 1.0))
        for (a, b, c) in ((x,y,z), (y,z,x), (z,x,y))
            for loc in ((a,b,c), (a,b,-c), (a,-b,c), (a,-b,-c), (-a,b,c), (-a,b,-c), (-a,-b,c), (-a,-b,-c))
                if loc ∉ res
                    push!(res, loc)
                end
            end
        end
    end
    return res
end

fullerene_graph = UnitDiskGraph(fullerene(), sqrt(5))
# g = SimpleGraph(fullerene_graph)

# gplot(g, layout=spring_layout)
# gplot(g, layout=stressmajorize_layout)

sg=SpinGlass(fullerene_graph, ones(Int, ne(fullerene_graph)), zeros(Int, nv(fullerene_graph)))

# Method 1: use TropicalMinPlus
tensors = [TropicalMinPlus.([J -J; -J J]) for J in sg.J]
rawcode = EinCode([[e.src, e.dst] for e in edges(fullerene_graph)], Int[])
optcode = optimize_code(rawcode, uniformsize(rawcode, 2), TreeSA())

Emin = optcode(tensors...)
# Emin=-66

# Method 2: use Simulated Annealing
# Method 3: use Monte Carlo
# using TensorInference

# β = 4.0
# pmodel = TensorNetworkModel(sg, β)
# samples = sample(pmodel, 1000)
# energy_distribution = energy.(Ref(sg), samples)
# Method 4: use Generic Tensor Network
# using GenericTensorNetworks
# solution=solve(sg, ConfigsMin())[]
# @show solution.n

# single_spin_tensors = [TropicalMinPlus.([h, -h]) for h in sg.h] # If with on-site potential, we could contract extra single bond tensors attached to each site. 
# If we want to solve the state, we could add config information to Tropical number, add contract with merging the config info.
