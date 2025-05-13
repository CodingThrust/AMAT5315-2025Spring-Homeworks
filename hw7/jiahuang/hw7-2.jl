
using ProblemReductions # Assuming SpinGlass, num_variables, energy are from here or a compatible local module
using Graphs # For SimpleGraph and graph operations like ne, nv

function triangle(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0.5, 0.5*sqrt(3))
    sites = vec([50 .*(a .* i .+ b .* j) for i=1:Na, j=1:Nb])
    graph_obj = ProblemReductions.UnitDiskGraph(vec(sites), 55.0) # graph_obj not graph
    g = SimpleGraph(graph_obj)
    return g
end

function squares(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0, 1)
    sites = vec([50 .*(a .* i .+ b .* j) for i=1:Na, j=1:Nb])
    graph_obj = ProblemReductions.UnitDiskGraph(vec(sites), 50.0) # graph_obj not graph
    g = SimpleGraph(graph_obj)
    return g
end

function diamonds(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0, 1)
    sites_base = vec([50 .* (a .* (j % 2 == 0 ? 2*i-1 : 2*i) .+ b .* j) for i=1:Na, j=1:Nb]) # sites_base not sites

    sites_extra = [50 .* (a .* (2*Na+1) .+b .*j) for j=2:2:Nb if Nb >= 2] # Handle Nb < 2 case
    
    all_sites = sites_base # Initialize with base sites
    if !isempty(sites_extra)
        all_sites = vcat(sites_base, sites_extra...) # Concatenate if extra sites exist
    end

    graph_obj = ProblemReductions.UnitDiskGraph(vec(all_sites), 50.0*sqrt(2.0)) # graph_obj not graph, ensure sqrt(2.0) for float
    g = SimpleGraph(graph_obj)
    return g
end

# Main script starts
using Pkg


using SparseArrays
using Arpack
using Plots
using JLD # JLD is fine, JLD2 is more modern but not strictly required by prompt.

# Assuming SpinGlass type and its methods num_variables, energy are defined,
# possibly through ProblemReductions or another included file not shown but implied by original script.
# If SpinGlass is defined in Lattice.jl, then include("./Lattice.jl") should work if Lattice.jl also has it.
# For this exercise, I'll assume SpinGlass and its methods are accessible.

# If SpinGlass is a custom struct, it might look something like this (example):
# struct SpinGlass
#     graph::SimpleGraph
#     J::Vector{Float64} # Or Int, depending on usage
#     h::Vector{Float64} # Or Int
#     N::Int
#     edge_to_idx::Dict{Edge, Int}
# end
# function SpinGlass(graph::SimpleGraph, J_values::Vector, h_values::Vector)
#     N = nv(graph)
#     edge_map = Dict{Edge, Int}()
#     for (k, edge) in enumerate(edges(graph))
#         edge_map[edge] = k
#     end
#     return SpinGlass(graph, J_values, h_values, N, edge_map)
# end
# num_variables(sg::SpinGlass) = sg.N
# function energy(sg::SpinGlass, σ_binary::Vector{Int}) # expects 0,1
#     spins = 2.0 .* σ_binary .- 1.0 # map {0,1} to {-1,1}
#     E = 0.0
#     for edge in edges(sg.graph)
#         idx = sg.edge_to_idx[edge]
#         u, v = src(edge), dst(edge)
#         E += sg.J[idx] * spins[u] * spins[v]
#     end
#     for i in 1:sg.N
#         E += sg.h[i] * spins[i]
#     end
#     return E
# end


function transition_matrix_sparse(sg::SpinGlass, beta::T) where T <: Real
    N = num_variables(sg)
    total_states = 2^N
    I_coords = Int[]   # Row indices
    J_coords = Int[]   # Column indices
    V_values = T[]     # Non-zero values
    
    sizehint!(I_coords, total_states * (N + 1))
    sizehint!(J_coords, total_states * (N + 1))
    sizehint!(V_values, total_states * (N + 1))
    
    readbit(cfg_int, i::Int) = (cfg_int >> (i - 1)) & 1
    int2cfg(cfg_int::Int, num_bits::Int) = [readbit(cfg_int, k) for k in 1:num_bits]
    
    for j_col_idx in 1:total_states # 1-based index for column
        cfg_j_int = j_col_idx - 1   # 0-based integer for spin configuration
        state_j_spins = int2cfg(cfg_j_int, N)
        energy_j = energy(sg, state_j_spins)
        
        sum_off_diag_prob = zero(T)
        
        for k_spin_flip in 1:N # Iterate over which spin to flip
            cfg_i_int = cfg_j_int ⊻ (1 << (k_spin_flip - 1))
            i_row_idx = cfg_i_int + 1 # 1-based index for row
            state_i_spins = int2cfg(cfg_i_int, N)
            energy_i = energy(sg, state_i_spins)
            
            delta_E = energy_i - energy_j
            prob = min(one(T), exp(-beta * delta_E)) / N # Glauber dynamics proposal
            
            push!(I_coords, i_row_idx)
            push!(J_coords, j_col_idx)
            push!(V_values, prob)
            sum_off_diag_prob += prob
        end
        
        diag_prob = one(T) - sum_off_diag_prob
        push!(I_coords, j_col_idx)
        push!(J_coords, j_col_idx)
        push!(V_values, diag_prob)
    end
    
    P = sparse(I_coords, J_coords, V_values, total_states, total_states)
    return P
end

function spectral_gap(P)
    # For very small matrices, eigs might require nev <= n-2 or similar.
    # total_states = size(P,1)
    # num_eigs = min(3, total_states - 1) 
    # if num_eigs < 2, spectral gap is ill-defined or handled differently.
    # For N>=2 (4 states), nev=3 is usually fine. Smallest N is 4 (2*2) in part 2.
    
    # If matrix is too small (e.g. 2x2, total_states=4 with N=2 needs nev<=2 if using complex eigs for real matrix)
    # Arpack typically handles this, but good to be aware.
    # We need at least 2 eigenvalues for the gap.
    if size(P,1) < 2
        return NaN # Or handle error appropriately
    elseif size(P,1) == 2 # For N=1, 2 states. graph(1,2) -> N=2.
        eigenvalues, _ = eigs(P, nev=2, which=:LR) # Need 2 eigs
    else
        eigenvalues, _ = eigs(P, nev=3, which=:LR) # Request 3, use 2nd.
    end

    # Eigenvalues are sorted by magnitude (real part for :LR, :SR).
    # First eigenvalue should be 1.0 for a stochastic matrix.
    # Second eigenvalue (in magnitude) is eigenvalues[2].
    # Gap is 1 - Re(lambda_2)
    return 1.0 - real(eigenvalues[2])
end

# Part 1: Analyse spectral gap v.s. at different temperature T (interpreted as beta)
println("Part 1: Calculating spectral gap vs beta...")
# Fixed graph sizes for this part
graphtri_fixed = triangle(9,2) # 18 nodes
graphsq_fixed = squares(9,2)  # 18 nodes
graphdi_fixed = diamonds(6,3) # 19 nodes

sgtri_fixed = SpinGlass(graphtri_fixed, ones(Int, ne(graphtri_fixed)), zeros(Int, nv(graphtri_fixed)))
sgsq_fixed = SpinGlass(graphsq_fixed, ones(Int, ne(graphsq_fixed)), zeros(Int, nv(graphsq_fixed)))
sgdi_fixed = SpinGlass(graphdi_fixed, ones(Int, ne(graphdi_fixed)), zeros(Int, nv(graphdi_fixed)))

beta_list = collect(0.1:0.4:2.0) # Name 'templis' in original, but it's used as beta
gaplistri = similar(beta_list)
gaplissq = similar(beta_list)
gaplisdi = similar(beta_list)

for (idx, beta_val) in enumerate(beta_list)
    println("Processing for beta = $beta_val")
    println("  N_tri=$(nv(graphtri_fixed)), N_sq=$(nv(graphsq_fixed)), N_di=$(nv(graphdi_fixed))")

    Ptri = transition_matrix_sparse(sgtri_fixed, beta_val)
    gaptri = spectral_gap(Ptri)
    gaplistri[idx] = gaptri
    println("  Triangle spectral gap = $gaptri")

    Psq = transition_matrix_sparse(sgsq_fixed, beta_val)
    gapsq = spectral_gap(Psq)
    gaplissq[idx] = gapsq
    println("  Squares spectral gap = $gapsq")

    Pdi = transition_matrix_sparse(sgdi_fixed, beta_val)
    gapdi = spectral_gap(Pdi)
    gaplisdi[idx] = gapdi
    println("  Diamonds spectral gap = $gapdi")
end

save("gapbeta.jld", "beta_list", beta_list, "gaptri", gaplistri, "gapsq", gaplissq, "gapdi", gaplisdi)

fig_beta = plot(beta_list, gaplistri, label="Triangles (N=$(nv(graphtri_fixed)))", xlabel="Beta", ylabel="Spectral gap", legend=:topleft)
plot!(fig_beta, beta_list, gaplissq, label="Squares (N=$(nv(graphsq_fixed)))")
plot!(fig_beta, beta_list, gaplisdi, label="Diamonds (N=$(nv(graphdi_fixed)))")
savefig(fig_beta, "./spectral_gap_vs_beta.png")
println("Saved plot to ./spectral_gap_vs_beta.png")

# Part 2: Analyse spectral gap v.s. the system size N at T = 0.1 (interpreted as beta = 0.1)
beta_for_N_scan = 0.1
println("\nPart 2: Calculating spectral gap vs N at beta = $beta_for_N_scan")

# Na_vals are the first parameter for the graph generation functions (e.g., width)
# Nb (second parameter) is fixed (2 for tri/sq, 3 for diamonds)
Na_vals_tri_sq = 2:9
Na_vals_dia = 2:6

# These plot_N_x_... arrays store the actual number of nodes (N) for x-axis
plot_N_x_tri_sq = [2*Na for Na in Na_vals_tri_sq]  # N = 4, 6, ..., 18
plot_N_x_dia = [3*Na + floor(Int, 3/2) for Na in Na_vals_dia] # N = 7, 10, ..., 19 (Nb=3)

gapNlistri = zeros(length(Na_vals_tri_sq))
gapNlissq = zeros(length(Na_vals_tri_sq))
gapNlisdi = zeros(length(Na_vals_dia))

println("Processing Triangles and Squares...")
for (idx, Na) in enumerate(Na_vals_tri_sq)
    actual_N_tri = 2*Na
    actual_N_sq = 2*Na
    println("  Na=$Na (Triangles N=$actual_N_tri, Squares N=$actual_N_sq)")
    
    graphtri = triangle(Na, 2)
    sgtri = SpinGlass(graphtri, ones(Int, ne(graphtri)), zeros(Int, nv(graphtri)))
    Ptri = transition_matrix_sparse(sgtri, beta_for_N_scan)
    gapNlistri[idx] = spectral_gap(Ptri)
    println("    Triangle (N=$(nv(graphtri))) spectral gap = ", gapNlistri[idx])

    graphsq = squares(Na, 2)
    sgsq = SpinGlass(graphsq, ones(Int, ne(graphsq)), zeros(Int, nv(graphsq)))
    Psq = transition_matrix_sparse(sgsq, beta_for_N_scan)
    gapNlissq[idx] = spectral_gap(Psq)
    println("    Square (N=$(nv(graphsq))) spectral gap = ", gapNlissq[idx])
end

println("Processing Diamonds...")
for (idx, Na) in enumerate(Na_vals_dia)
    actual_N_dia = 3*Na + floor(Int, 3/2) # Assuming Nb=3
    println("  Na=$Na (Diamonds N=$actual_N_dia)")

    graphdi = diamonds(Na, 3) # Nb=3 consistent with node count formula
    sgdi = SpinGlass(graphdi, ones(Int, ne(graphdi)), zeros(Int, nv(graphdi)))
    Pdi = transition_matrix_sparse(sgdi, beta_for_N_scan)
    gapNlisdi[idx] = spectral_gap(Pdi)
    println("    Diamond (N=$(nv(graphdi))) spectral gap = ", gapNlisdi[idx])
end

save("gapNlis.jld", "plot_N_x_tri_sq", plot_N_x_tri_sq, "gapNlistri", gapNlistri,
                        "plot_N_x_dia", plot_N_x_dia, "gapNlisdi", gapNlisdi,
                        "gapNlissq", gapNlissq) # plot_N_x_sq is same as plot_N_x_tri_sq

fig_N = plot(plot_N_x_tri_sq, gapNlistri, label="Triangles", xlabel="N (Number of nodes)", ylabel="Spectral gap", legend=:topleft)
plot!(fig_N, plot_N_x_tri_sq, gapNlissq, label="Squares")
plot!(fig_N, plot_N_x_dia, gapNlisdi, label="Diamonds")

# Consolidate and sort ticks for better readability if ranges overlap significantly
all_N_values = sort(unique(vcat(plot_N_x_tri_sq, plot_N_x_dia)))
plot!(fig_N, xticks=all_N_values)
savefig(fig_N, "./spectral_gap_vs_N.png")
println("Saved plot to ./spectral_gap_vs_N.png")

println("Script finished.")