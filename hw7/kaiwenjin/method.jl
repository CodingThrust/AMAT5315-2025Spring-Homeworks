using SparseArrays,LinearAlgebra,KrylovKit,Random,Plots

function generate_topology_matrix(N::Int64,topology_type::String)
    if topology_type == "triangles"
        return generate_triangles(N)
    elseif topology_type == "squares"
        return generate_squares(N)
    elseif topology_type == "diamonds"
        return generate_diamonds(N)
    else
        error("No such topology type: $(topology_type). Please use 'triangles', 'squares' or 'diamonds'")
    end
end

function generate_triangles(n_vertices::Int)
    n_groups = ceil(Int, n_vertices/2)
    A = spzeros(n_vertices, n_vertices) 
    for i in 1:n_groups
        idx1 = 2*i - 1
        idx2 = 2*i     
        if idx2 > n_vertices
            break
        end   
        A[idx1, idx2] = 1
        A[idx2, idx1] = 1     
        if i > 1
            prev_idx1 = 2*i - 3
            prev_idx2 = 2*i - 2
            
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
    n_groups = ceil(Int, n_vertices/2)    
    A = spzeros(n_vertices, n_vertices)
    for i in 1:n_groups
        idx1 = 2*i - 1
        idx2 = 2*i   
        if idx2 > n_vertices
            break
        end        
        A[idx1, idx2] = 1
        A[idx2, idx1] = 1   
        if i > 1
            prev_idx1 = 2*i - 3
            prev_idx2 = 2*i - 2
            
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
    for i in 1:n_diamonds
        top_idx = 3*i - 1
        bottom_idx = 3*i
        right_idx = 3*i + 1   
        if right_idx > n_vertices
            break
        end   
        if i == 1
            A[start_idx, top_idx] = 1
            A[top_idx, start_idx] = 1
            
            A[start_idx, bottom_idx] = 1
            A[bottom_idx, start_idx] = 1
        else
            prev_right_idx = 3*(i-1) + 1
            
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
    
    remaining = n_vertices - (3*n_diamonds + 1)
    if remaining > 0
        last_right_idx = 3*n_diamonds + 1
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

function generate_hamiltonian(A::SparseMatrixCSC, t::Float64)
    n = size(A,1)
    state2num = Vector{Int64}(undef,n)
    for i=1 : n
        state2num[i] = 2^(i-1)
    end
    N = 2^n
    H = spzeros(N,N)

    function _prob(state::Vector,state1::Vector)
        energy = (2*state .- 1)'*A*(2*state .- 1)
        energy1 = (2*state1 .- 1)'*A*(2*state1 .- 1)
        Δ = energy1 - energy
        return Δ<0 ? 1 : exp(-Δ/t)
    end
    for i in 0:N-1
        state = zeros(n)
        i1 = i
        for j in 1:n
            state[j] = i1&1
            i1 = i1>>1
        end
        for j in 1:n
            state1 = copy(state)
            state1[j] = 1 - state1[j]
            i2 = round(Int64,sum(state1.*state2num))
            H[i+1,i2+1] = _prob(state,state1)
        end
    end
    return H
end