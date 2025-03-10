using CairoMakie
using SpringSystem
using SpringSystem: eigenmodes, eigensystem, nv
using LinearAlgebra
using Graphs

function revised_spring_chain(offsets::Vector{<:Real}, stiffness::Real, masses::Vector{<:Real}; periodic::Bool=false)
    n = length(offsets)
    
    if length(masses) != n
        error("The length of the masses vector must match the number of particles.")
    end
    
    r = [SpringSystem.Point((i * 1.0, 0.0)) for i in 0:n-1]  
    dr = [SpringSystem.Point((Float64(offset), 0.0)) for offset in offsets]  
    v = fill(SpringSystem.Point((0.0, 0.0)), n)  
    topology = path_graph(n)  
    if periodic
        add_edge!(topology, n, 1)  
    end
    return SpringModel(r, dr, v, topology, fill(stiffness, n), masses)
end

function run_spring_chain(; C = 3.0, M = [i % 2 == 0 ? 2.0 : 1.0 for i in 1:21], L = 21, u0 = 0.2 * randn(L))
    spring = revised_spring_chain(u0, C, M; periodic=false)

    @info """Setup spring chain model:
    - mass = $M
    - stiffness = $C
    - length of chain = $L
    """
    @info """Simulating with leapfrog symplectic integrator:
    - dt = 0.1
    - number of steps = 500
    """
    simulated = leapfrog_simulation(spring; dt=0.1, nsteps=500)
    @info """Solving the spring system exactly with eigenmodes"""
    exact = waveat(eigenmodes(eigensystem(spring)), u0, 0.1 * (0:500))

    return simulated, exact
end

simulated, exact = run_spring_chain()
modes = eigenmodes(eigensystem(simulated[1].sys))
frequencies = modes.frequency
println("Eigenfrequencies: ", sort(frequencies))