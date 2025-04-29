using ProblemReductions, GenericTensorNetworks
using SpinDynamics
using Graphs

circuit = @circuit begin
    s = x ⊻ y  
    c = x ∧ y
end

circuitsat = CircuitSAT(circuit)
result = reduceto(SpinGlass{<:SimpleGraph}, circuitsat)

SG=target_problem(result)
ground_state = read_config(solve(SG, SingleConfigMin())[])


# indexof(x) = findfirst(==(x), circuitsat.symbols[sortperm(result.variables)])

# gadget = LogicGadget(result.spinglass, indexof.([:x, :y]), [indexof(:c), indexof(:s)])
# tb = truth_table(gadget; variables=circuitsat.symbols[sortperm(result.variables)])
#= =#
############## ------#########

graph = SG.graph
J= Float64.(SG.J)
h= Float64.(SG.h)


initial_scale = 0.1 
initial_x = randn(nv(graph)) .* initial_scale
initial_p = randn(nv(graph)) .* initial_scale
initial_state = SimulatedBifurcationState(initial_x, initial_p)


bifurcation_model = SimulatedBifurcation{:aSB}(graph, J, c0=0.04902903378454601)


nsteps = 1000
dt = 0.01
state, checkpoints = simulate_bifurcation!(initial_state, bifurcation_model; nsteps=nsteps, dt=dt)

# times = getfield.(checkpoints, :time)
# potential_energies = getfield.(checkpoints, :potential_energy)
# kinetic_energies = getfield.(checkpoints, :kinetic_energy)
# total_energies = potential_energies .+ kinetic_energies

resolution=100
xmax =  1.0
x_range = range(-xmax, xmax, length=resolution)
y_range = range(-xmax, xmax, length=resolution)

# final_energy = SpinDynamics.potential_energy.(Ref(bifurcation_model), [[x, y] for x in x_range, y in y_range])

xs = [s.state.x[1] for s in checkpoints]
ys = [s.state.x[2] for s in checkpoints]

# ground_state = read_config(solve(SG, SingleConfigMin())[])
# @info "Ground state configuration: $(ground_state)"