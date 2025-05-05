using CrystalStructurePrediction
using CairoMakie, SCIP
using BenchmarkTools

# paras=Dict([])
paras = Dict([
    # 核心控制
    ("presolving/maxrestarts", 0),            # 禁用自动重启
    ("propagating/obbt/freq", -1),            # 关闭耗时OBBT传播
    ("constraints/countsols/collect", 1),     # 增强解计数分析
    
    # 对称性处理
    ("propagating/symmetry/priority", 10000),                   # 启用强对称处理
    ("propagating/symmetry/freq", 10),            
    
    # 分支策略优化
    ("branching/relpscost/priority", 5000),   # 可靠性伪成本分支
    ("branching/vanillafullstrong/idempotent", false),# 完全强分支缓存
    
    # 割平面强化
    ("separating/clique/freq", 10),           # 启用clique割
    ("separating/zerohalf/freq", 5),          # 零半割加强
    ("separating/gomory/freq", 3),            # 更积极的Gomory割
    
    # 启发式优化
    ("heuristics/undercover/freq", 20),       # 覆盖式启发
    ("heuristics/proximity/freq", 15),        # 邻近搜索
    ("heuristics/shifting/freq", 10),         # 增强位移启发
    
    # LP求解优化
    # ("lp/resolvealgorithm", "b"),             # 屏障法解初始LP
    ("lp/threads", 2),                        # 限制LP线程避免争抢
    
    # 数值稳定性
    ("numerics/feastol", 1e-6),               # 恢复默认精度
    ("numerics/lpfeastolfactor", 1e-3)              # 加强LP精度
])
# Run the crystal structure prediction, alpha is the Ewald parameter

function myoptimize_linear(interaction,
    ions::AbstractVector{Ion{D, T}},
    populations::Dict{IonType{T}, Int},  # a dictionary of ion types and their populations
    lattice::Lattice;
    optimizer = SCIP.Optimizer,
    optimizer_options = Dict(),
    proximal_threshold = 0.75
) where {D, T<:Real}
# build the model
csp = Model(optimizer);
num_ions = length(ions)
unique_coordinates = unique!([ion.frac_pos for ion in ions])
@variable(csp, 0 <= x[1:num_ions] <= 1, Int)
@variable(csp, 0 <= s[1:num_ions*(num_ions-1)÷2] <= 1, Int)

# each ion type has a constraint on the number of ions of that type
for (type, population) in populations
@constraint(csp, sum(x[i] for i in range(1, num_ions) if ions[i].type == type) == population)
end
# each grid point has at most one ion
for coord in unique_coordinates
@constraint(csp, sum(x[i] for i in range(1, num_ions) if ions[i].frac_pos == coord) <= 1)
end
# ions are not allowed to be too close to each other
for i in 1:num_ions-1, j in i+1:num_ions
if CrystalStructurePrediction.too_close(ions[i], ions[j], lattice, proximal_threshold)
    @constraint(csp, x[i] + x[j] <= 1)
end
end
# s is a "matrix" representing the co-existence of ions
energy = zero(eltype(s))
for i in range(1, num_ions-1)
for j in range(i+1, num_ions)
    @constraint(csp, s[i + (j-1)*(j-2)÷2] <= x[i])
    @constraint(csp, s[i + (j-1)*(j-2)÷2] <= x[j])
    @constraint(csp, s[i + (j-1)*(j-2)÷2] >= x[i] + x[j] - 1)
    energy += interaction(ions[i], ions[j], lattice) * s[i + (j-1)*(j-2)÷2]
end
end 
# minimize the interaction energy
@objective(csp, Min, energy)
# set the optimizer options
for (key, value) in optimizer_options
set_optimizer_attribute(csp, key, value)
end
# solve the problem
optimize!(csp)
assert_is_solved_and_feasible(csp)
return CrystalStructurePrediction.IonOptimizationResult(objective_value(csp), [ions[i] for i in 1:num_ions if value.(x)[i] ≈ 1])
end

function run_crystal_structure_prediction(grid_size, populations, lattice; use_quadratic_problem::Bool=false)
    alpha = 2 / maximum(lattice.vectors)
    # @info "Setting up crystal structure prediction with"
    # @info "Grid size: $grid_size"
    # @info "Populations: $populations"
    # @info "Ewald parameter: $alpha"
    
    # Build ion list and proximal pairs
    ion_list = ions_on_grid(grid_size, collect(keys(populations)))
    # @info "Created ion list with $(length(ion_list)) possible ion positions"
    
    # Ewald summation parameters
    depth = (4, 4, 4)
    if use_quadratic_problem
        # Solve with the quadratic formulation
        # @info "Solving quadratic optimization problem..."
        res = optimize_quadratic(ion_list, populations, lattice; optimizer=SCIP.Optimizer) do ion_a, ion_b, lattice
            interaction_energy(ion_a, ion_b, lattice, alpha, depth, depth, depth)
        end
    else
        # Solve with the linear formulation
        # @info "Solving linear optimization problem..."
        res = optimize_linear(ion_list, populations, lattice; optimizer=SCIP.Optimizer, optimizer_options=paras) do ion_a, ion_b, lattice
            interaction_energy(ion_a, ion_b, lattice, alpha, depth, depth, depth)
        end
    end
    # Display results
    # @info "Optimization complete with energy: $(res.energy)"
    # for ion in res.selected_ions
    #     @info "Ion: $ion"
    # end
    return res
end

# Visualize the crystal structure
function visualize_crystal_structure(selected_ions, lattice, shift)
    fig = Figure(; size = (300, 250))
    ax = Axis3(fig[1, 1], 
               aspect = :data,
               xlabel = "x", ylabel = "y", zlabel = "z",
               title = "SrTiO3 Crystal Structure")
       
    # Add unit cell edges
    cell_vertices = [
        [0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0],
        [0, 0, 1], [1, 0, 1], [1, 1, 1], [0, 1, 1]
    ]
    
    # Convert to Cartesian coordinates
    cell_vertices_cart = [lattice.vectors * v for v in cell_vertices]
    
    # Define edges of the unit cell
    edges = [
        (1, 2), (2, 3), (3, 4), (4, 1),  # Bottom face
        (5, 6), (6, 7), (7, 8), (8, 5),  # Top face
        (1, 5), (2, 6), (3, 7), (4, 8)   # Connecting edges
    ]
    
    # Plot unit cell edges
    for (i, j) in edges
        lines!(ax, 
               [cell_vertices_cart[i][1], cell_vertices_cart[j][1]],
               [cell_vertices_cart[i][2], cell_vertices_cart[j][2]],
               [cell_vertices_cart[i][3], cell_vertices_cart[j][3]],
               color = :black, linewidth = 1)
    end
    
    # Plot the ions
    properties = Dict(:Sr => (color = :green,), :Ti => (color = :aqua,), :O => (color = :red,))
    
    # Plot each ion
    for ion in selected_ions
        # Plot the ion at its position and all periodic images within the unit cell
        coordinates = []
        for dx in -1:1, dy in -1:1, dz in -1:1
            # Add periodic image shift vector
            offset = [dx, dy, dz] .+ shift
            # Skip if the shifted position is outside the unit cell (0-1 range)
            shifted_pos = ion.frac_pos + offset
            if all(0 .<= shifted_pos .<= 1)
                # Convert to Cartesian coordinates
                shifted_cart_pos = lattice.vectors * shifted_pos
                push!(coordinates, shifted_cart_pos)
            end
        end
        scatter!(ax, coordinates, 
                    color = properties[ion.type.species].color, 
                    markersize = ion.type.radii * 20,
                    label = string(ion.type.species))
    end
 
    # Add legend with unique entries
    unique_species = unique([ion.type for ion in selected_ions])
    legend_elements = [MarkerElement(color = properties[sp.species].color, marker = :circle, markersize = sp.radii * 20) for sp in unique_species]
    legend_labels = [string(sp.species) for sp in unique_species]
    
    Legend(fig[1, 2], legend_elements, legend_labels, "Species", patchsize = (30, 30))
    # Remove decorations and axis
    hidedecorations!(ax)
    hidespines!(ax)
    return fig
end

####### Run the prediction #######
function run_SrTiO3_prediction()
    # Crystal structure parameters
    lattice_constant = 3.899  # Å
    lattice = Lattice(lattice_constant .* [1 0 0; 0 1 0; 0 0 1])
    grid_size = (2, 2, 2)
    populations = Dict(
        IonType(:Sr, +2, 1.18) => 1,  # 1 Sr atom
        IonType(:Ti, +4, 0.42) => 1,  # 1 Ti atom
        IonType(:O, -2, 1.35) => 3    # 3 O atoms
    )

    res = run_crystal_structure_prediction(grid_size, populations, lattice; use_quadratic_problem=false)

    # Generate and save the visualization
    origin = res.selected_ions[findfirst(x -> x.type.species == :Sr, res.selected_ions)].frac_pos
    fig = visualize_crystal_structure(res.selected_ions, lattice, origin)

    filename = joinpath(@__DIR__, "SrTiO3-structure.png")
    save(filename, fig, dpi=20)
    # @info "Saved crystal structure visualization to: $filename"
end


@btime run_SrTiO3_prediction()
# Initial 408.549 ms (268006 allocations: 21.76 MiB)
# After tuning 190.641 ms (267354 allocations: 21.74 MiB)
