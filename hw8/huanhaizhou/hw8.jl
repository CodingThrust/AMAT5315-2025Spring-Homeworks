using Pkg
Pkg.activate("./hw8/huanhaizhou/SpinDynamics")
Pkg.instantiate()

using ProblemReductions, GenericTensorNetworks
using SpinDynamics
using Graphs
using Plots

# Problem 1
circuit = @circuit begin
    s = x ⊻ y  
    c = x ∧ y
end

circuitsat = CircuitSAT(circuit)
result = reduceto(SpinGlass{<:SimpleGraph}, circuitsat)

SG=target_problem(result)

for e in edges(SG.graph)
    @show e
end
@show SG.h
@show SG.J
