using SparseArrays, LinearAlgebra, KrylovKit, Random, Plots

function generate_topology_matrix(N::Int64, topology_type::String)
    if topology_type == "triangles"
        return generate_triangles(N) / 2
    elseif topology_type == "squares"
        return generate_squares(N) / 2
    elseif topology_type == "diamonds"
        return generate_diamonds(N) / 2
    else
        error(
            "No such topology type: $(topology_type). Please use 'triangles', 'squares' or 'diamonds'",
        )
    end
end

function generate_triangles(n_vertices::Int)
    n_groups = ceil(Int, n_vertices / 2)
    A = spzeros(n_vertices, n_vertices)
    for i = 1:n_groups
        idx1 = 2 * i - 1
        idx2 = 2 * i
        if idx2 > n_vertices
            break
        end
        A[idx1, idx2] = 1
        A[idx2, idx1] = 1
        if i > 1
            prev_idx1 = 2 * i - 3
            prev_idx2 = 2 * i - 2

            A[prev_idx1, idx1] = 1
            A[idx1, prev_idx1] = 1

            A[prev_idx2, idx1] = 1
            A[idx1, prev_idx2] = 1

            A[prev_idx2, idx2] = 1
            A[idx2, prev_idx2] = 1
        end
    end
    return A
end

function generate_squares(n_vertices::Int)
    n_groups = ceil(Int, n_vertices / 2)
    A = spzeros(n_vertices, n_vertices)
    for i = 1:n_groups
        idx1 = 2 * i - 1
        idx2 = 2 * i
        if idx2 > n_vertices
            break
        end
        A[idx1, idx2] = 1
        A[idx2, idx1] = 1
        if i > 1
            prev_idx1 = 2 * i - 3
            prev_idx2 = 2 * i - 2

            A[prev_idx1, idx1] = 1
            A[idx1, prev_idx1] = 1

            A[prev_idx2, idx2] = 1
            A[idx2, prev_idx2] = 1
        end
    end
    return A
end

function generate_diamonds(n_vertices::Int)
    A = spzeros(n_vertices, n_vertices)
    start_idx = 1
    n_diamonds = floor(Int, (n_vertices - 1) / 3)
    for i = 1:n_diamonds
        top_idx = 3 * i - 1
        bottom_idx = 3 * i
        right_idx = 3 * i + 1
        if right_idx > n_vertices
            break
        end
        if i == 1
            A[start_idx, top_idx] = 1
            A[top_idx, start_idx] = 1

            A[start_idx, bottom_idx] = 1
            A[bottom_idx, start_idx] = 1
        else
            prev_right_idx = 3 * (i - 1) + 1

            A[prev_right_idx, top_idx] = 1
            A[top_idx, prev_right_idx] = 1

            A[prev_right_idx, bottom_idx] = 1
            A[bottom_idx, prev_right_idx] = 1
        end

        A[top_idx, right_idx] = 1
        A[right_idx, top_idx] = 1

        A[bottom_idx, right_idx] = 1
        A[right_idx, bottom_idx] = 1
    end

    remaining = n_vertices - (3 * n_diamonds + 1)
    if remaining > 0
        last_right_idx = 3 * n_diamonds + 1
        if remaining == 1
            top_idx = last_right_idx + 1

            A[last_right_idx, top_idx] = 1
            A[top_idx, last_right_idx] = 1
        elseif remaining == 2
            top_idx = last_right_idx + 1
            bottom_idx = last_right_idx + 2

            A[last_right_idx, top_idx] = 1
            A[top_idx, last_right_idx] = 1

            A[last_right_idx, bottom_idx] = 1
            A[bottom_idx, last_right_idx] = 1
        end
    end
    return A
end

function generate_trans(A::SparseMatrixCSC, t::T) where {T<:Real}
    n = size(A, 1)
    N = 2^n
    state2num = [2^(i - 1) for i = 1:n]

    idx_i = Vector{Int}(undef, N * (n+1))
    idx_j = Vector{Int}(undef, N * (n+1))
    values = Vector{T}(undef, N * (n+1))
    dH = zeros(T, N)

    function _prob(state::Vector, flip_idx::Int)
        state1 = 2 * state .- 1
        Δ = -2 * sum(state1[flip_idx] * state1 .* A[flip_idx, :])
        return Δ < 0.0 ? 1.0 : exp(-Δ / t)
    end
    state = zeros(n)
    state1 = zeros(n)
    idx = 0

    @inbounds for i = 0:(N-1)
        i1 = i
        idx_i[n*N+i+1] = idx_j[n*N+i+1] = i+1
        for j = 1:n
            state[j] = i1 & 1
            i1 = i1 >> 1
        end

        for j = 1:n
            copyto!(state1, state)
            state1[j] = 1 - state1[j]
            i2 = round(Int64, sum(state1 .* state2num))

            idx_i[idx+1] = i + 1
            idx_j[idx+1] = i2 + 1
            values[idx+1] = _prob(state, j)
            dH[i2+1] += values[idx+1]
            idx += 1
        end
    end
    values[(n*N+1):end] .= 1 .- dH/n
    values[1:(n*N)] .= values[1:(n*N)] ./ n
    return sparse(idx_i, idx_j, values, N, N)
end
