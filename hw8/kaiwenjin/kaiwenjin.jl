using LinearAlgebra, Test, Random
Random.seed!(1234)

#########################################################
# 1. 
#########################################################

#=
A → !A, B → !B
S = (A & !B) | (!A & B)
C  = !A | !B
bench_io is set of (A,B,S,C)
=#
bench_io = Set([[-1, -1, -1, 1], [-1, 1, 1, 1], [1, -1, 1, 1], [1, 1, -1, -1]])

#=
encode it into spinglass and the vertex is 
[A, B, !A, !B, A&!B, !A&B, A&!B, !A&B, !A, !B, A⊕B, !A|!B]
=#
function generate_H()
	H = zeros(12, 12)
    b = zeros(12)
    b[1] = b[2] = b[3] = b[4] = -1
    b[5] = b[6] = 2
    b[7] = b[8] = b[9] = b[10] = 1
    b[11] = b[12] = -2
    H[1,3] = H[1,4] = H[2,4] = H[2,3] = 1
    H[1,6] = H[2,5] = H[3,5] = H[4,6] = -2
    H[3,9] = H[4,10] = H[5,7] = H[6,8] = -1
    H[7,8] = 1
    H[7,11] = H[8,11] = -2
    H[9,10] = 1
    H[9,12] = H[10,12] = -2
    return (H+H')/2,b
end
H,b = generate_H()
#= The reduced result is
  0.0   0.0   0.5   0.5   0.0  -1.0   0.0   0.0   0.0   0.0   0.0   0.0
  0.0   0.0   0.5   0.5  -1.0   0.0   0.0   0.0   0.0   0.0   0.0   0.0
  0.5   0.5   0.0   0.0  -1.0   0.0   0.0   0.0  -0.5   0.0   0.0   0.0
  0.5   0.5   0.0   0.0   0.0  -1.0   0.0   0.0   0.0  -0.5   0.0   0.0
  0.0  -1.0  -1.0   0.0   0.0   0.0  -0.5   0.0   0.0   0.0   0.0   0.0
 -1.0   0.0   0.0  -1.0   0.0   0.0   0.0  -0.5   0.0   0.0   0.0   0.0
  0.0   0.0   0.0   0.0  -0.5   0.0   0.0   0.5   0.0   0.0  -1.0   0.0
  0.0   0.0   0.0   0.0   0.0  -0.5   0.5   0.0   0.0   0.0  -1.0   0.0
  0.0   0.0  -0.5   0.0   0.0   0.0   0.0   0.0   0.0   0.5   0.0  -1.0
  0.0   0.0   0.0  -0.5   0.0   0.0   0.0   0.0   0.5   0.0   0.0  -1.0
  0.0   0.0   0.0   0.0   0.0   0.0  -1.0  -1.0   0.0   0.0   0.0   0.0
  0.0   0.0   0.0   0.0   0.0   0.0   0.0   0.0  -1.0  -1.0   0.0   0.0
=#

# Now we check the correctness of the result
function energy(state, H, b)
    return state' * H * state + b' * state
end
function ground_state(H,b)
    n = size(H, 1)
    ground_energy = Inf
    ground_state = Set{Vector{Int64}}()
    for i in 0:2^n-1
        state = [((i>>j) & 1) for j in 0:n-1]
        state = state .* 2 .- 1
        E = energy(state, H, b)
        if E == ground_energy
            push!(ground_state, state)
        elseif E < ground_energy
            ground_energy = E
            empty!(ground_state)
            push!(ground_state, state)
        end
    end
    return ground_state
end

gs = ground_state(H,b)
gs_io = Set{Vector{Int64}}()
while !isempty(gs)
    state = pop!(gs)
    push!(gs_io, vcat(state[1:2], state[end-1:end]))
end
@test gs_io == bench_io



#########################################################
# 2. 
#########################################################
function random_neighbor(state, allowed_indices)
    new_state = copy(state)
    idx = rand(allowed_indices)
    new_state[idx] *= -1
    return new_state
end

function simulated_annealing(H, b; 
    T_init = 10.0, 
    T_min = 1e-3, 
    alpha = 0.95, 
    max_iter = 10000,
    fixed_indices = Int[], 
    fixed_values = Int[])
    n = length(b)

    state = [rand(Bool) ? 1 : -1 for _ in 1:n]
    for (i, v) in zip(fixed_indices, fixed_values)
        state[i] = v
    end
    
    T = T_init
    best_state = copy(state)
    best_energy = energy(state, H, b)
    allowed_indices = setdiff(1:n, fixed_indices)
    iter = 0

    while T > T_min && iter < max_iter
        iter += 1
        new_state = random_neighbor(state, allowed_indices)
        for (i, v) in zip(fixed_indices, fixed_values)
            new_state[i] = v
        end

        ΔE = energy(new_state, H, b) - energy(state, H, b)

        if ΔE <= 0 || rand() < exp(-ΔE / T)
            state = new_state
            if energy(state, H, b) < best_energy
                best_energy = energy(state, H, b)
                best_state = copy(state)
            end
        end
        
        T *= alpha
    end
    return best_state, best_energy
end

spins = simulated_annealing(H, b)

A,B = (spins[1][1:2] .+ 1) .÷ 2
println("A spin: ", A) # 0
println("B spin: ", B) # 0


