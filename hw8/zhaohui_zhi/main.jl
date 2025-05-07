using Pkg
Pkg.activate("./hw8/zhaohui_zhi")
Pkg.instantiate()
using ProblemReductions, GenericTensorNetworks
using SpinDynamics
using Graphs
using Plots

circuit = @circuit begin
    s = x ⊻ y  
    c = x ∧ y
end

circuitsat = CircuitSAT(circuit)
result = reduceto(SpinGlass{<:SimpleGraph}, circuitsat)

SG=target_problem(result)
ground_state = read_config(solve(SG, SingleConfigMin())[])

x_idx = findfirst(==(:x), circuitsat.symbols)
y_idx = findfirst(==(:y), circuitsat.symbols)
s_idx = findfirst(==(:s), circuitsat.symbols)
c_idx = findfirst(==(:c), circuitsat.symbols)
# indexof(x) = findfirst(==(x), circuitsat.symbols[sortperm(result.variables)])

# gadget = LogicGadget(result.spinglass, indexof.([:x, :y]), [indexof(:c), indexof(:s)])
# tb = truth_table(gadget; variables=circuitsat.symbols[sortperm(result.variables)])
#= =#
############## ------#########

graph = SG.graph
J= Float64.(SG.J)
h= Float64.(SG.h)

N= nv(graph)

initial_scale = 0.1 
# initial_x = randn(N) .* initial_scale # Initial state for the x and y variables
initial_x= randn(N) .* initial_scale
initial_p = randn(N) .* initial_scale
initial_state = SimulatedBifurcationState(initial_x, initial_p)

c0=0.5/(√N*√(sum(x -> x^2, J)/(N*(N-1))))
bifurcation_model = SimulatedBifurcation{:aSB}(graph, zeros(length(h)), J, c0=c0)


nsteps = 10000
dt = 0.01
state, checkpoints = simulate_bifurcation!(initial_state, bifurcation_model; nsteps=nsteps, dt=dt,  checkpoint_steps=5)

# times = getfield.(checkpoints, :time)
# potential_energies = getfield.(checkpoints, :potential_energy)
# kinetic_energies = getfield.(checkpoints, :kinetic_energy)
# total_energies = potential_energies .+ kinetic_energies

# plot(times, total_energies, label="Total Energy", xlabel="Time", ylabel="Energy", title="Energy vs Time", legend=:topright)
# final_energy = SpinDynamics.potential_energy.(Ref(bifurcation_model), [[x, y] for x in x_range, y in y_range])

# @show xs[end], ys[end]

println(checkpoints[end].state.x)
@show "x=" checkpoints[end].state.x[x_idx]
@show "y=" checkpoints[end].state.x[y_idx]
@show "s=" checkpoints[end].state.x[s_idx]
@show "c=" checkpoints[end].state.x[c_idx]
# The GS is xysc=1010

# Fix the output S=0, C=1

h= Float64.(SG.h)

h[s_idx]=-1e3
h[c_idx]=1e3


initial_scale = 0.1 
# initial_x = randn(N) .* initial_scale # Initial state for the x and y variables
initial_x= randn(N) .* initial_scale
initial_p = randn(N) .* initial_scale
initial_state = SimulatedBifurcationState(initial_x, initial_p)


bifurcation_model = SimulatedBifurcation{:aSB}(graph,h, J, c0=c0)


nsteps = 10000
dt = 0.01
state, checkpoints = simulate_bifurcation!(initial_state, bifurcation_model; nsteps=nsteps, dt=dt,  checkpoint_steps=5)

println(checkpoints[end].state.x)
@show "x=" checkpoints[end].state.x[x_idx]
@show "y=" checkpoints[end].state.x[y_idx]
@show "s=" checkpoints[end].state.x[s_idx]
@show "c=" checkpoints[end].state.x[c_idx]
#The input x=0, y=1

# ground_state = read_config(solve(SG, SingleConfigMin())[])
# @info "Ground state configuration: $(ground_state)"