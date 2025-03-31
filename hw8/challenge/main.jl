using Yao

# Load functions to read qflex qasm files.
include("circuit.jl")
using .YaoQASMReader: yaocircuit_from_qasm

# circuit source: https://github.com/brenjohn/Contraction-Order-Bench/tree/main/data/circuits
cirq_name = "sycamore_53_20_0"
@info("running circuit: $(cirq_name)")

# Create the TensorNetworkCircuit object for the circuit
qasm_file = joinpath(@__DIR__, cirq_name * ".txt")
c = yaocircuit_from_qasm(qasm_file)
using Random; Random.seed!(2)
time_elapsed = @elapsed net = yao2einsum(c, initial_state=Dict(zip(1:nqubits(c), zeros(Int,nqubits(c)))), final_state=Dict(zip(1:nqubits(c), zeros(Int,nqubits(c)))), optimizer=TreeSA(ntrials=10, niters=20, sc_target=52))
@info "contraction complexity: $(contraction_complexity(net)), time cost: $(time_elapsed)s"