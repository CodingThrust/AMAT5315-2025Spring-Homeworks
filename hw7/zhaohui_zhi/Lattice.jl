# function generate_triangles(n_vertices::Int)
# 	n_groups = ceil(Int, n_vertices / 2)
# 	A = zeros(n_vertices, n_vertices)
# 	for i in 1:n_groups
# 		idx1 = 2 * i - 1
# 		idx2 = 2 * i
# 		if idx2 > n_vertices
# 			break
# 		end
# 		A[idx1, idx2] = 1
# 		A[idx2, idx1] = 1
# 		if i > 1
# 			prev_idx1 = 2 * i - 3
# 			prev_idx2 = 2 * i - 2

# 			A[prev_idx1, idx1] = 1
# 			A[idx1, prev_idx1] = 1

# 			A[prev_idx2, idx1] = 1
# 			A[idx1, prev_idx2] = 1

# 			A[prev_idx2, idx2] = 1
# 			A[idx2, prev_idx2] = 1
# 		end
# 	end
# 	return A
# end

# function generate_squares(n_vertices::Int)
# 	n_groups = ceil(Int, n_vertices / 2)
# 	A = zeros(n_vertices, n_vertices)
# 	for i in 1:n_groups
# 		idx1 = 2 * i - 1
# 		idx2 = 2 * i
# 		if idx2 > n_vertices
# 			break
# 		end
# 		A[idx1, idx2] = 1
# 		A[idx2, idx1] = 1
# 		if i > 1
# 			prev_idx1 = 2 * i - 3
# 			prev_idx2 = 2 * i - 2

# 			A[prev_idx1, idx1] = 1
# 			A[idx1, prev_idx1] = 1

# 			A[prev_idx2, idx2] = 1
# 			A[idx2, prev_idx2] = 1
# 		end
# 	end
# 	return A
# end

# function generate_diamonds(n_vertices::Int)
# 	A = zeros(n_vertices, n_vertices)
# 	start_idx = 1
# 	n_diamonds = floor(Int, (n_vertices - 1) / 3)
# 	for i in 1:n_diamonds
# 		top_idx = 3 * i - 1
# 		bottom_idx = 3 * i
# 		right_idx = 3 * i + 1
# 		if right_idx > n_vertices
# 			break
# 		end
# 		if i == 1
# 			A[start_idx, top_idx] = 1
# 			A[top_idx, start_idx] = 1

# 			A[start_idx, bottom_idx] = 1
# 			A[bottom_idx, start_idx] = 1
# 		else
# 			prev_right_idx = 3 * (i - 1) + 1

# 			A[prev_right_idx, top_idx] = 1
# 			A[top_idx, prev_right_idx] = 1

# 			A[prev_right_idx, bottom_idx] = 1
# 			A[bottom_idx, prev_right_idx] = 1
# 		end

# 		A[top_idx, right_idx] = 1
# 		A[right_idx, top_idx] = 1

# 		A[bottom_idx, right_idx] = 1
# 		A[right_idx, bottom_idx] = 1
# 	end

#     remaining = n_vertices - (3 * n_diamonds + 1)
# 	if remaining > 0
# 		last_right_idx = 3 * n_diamonds + 1
# 		if remaining == 1
# 			top_idx = last_right_idx + 1

# 			A[last_right_idx, top_idx] = 1
# 			A[top_idx, last_right_idx] = 1
# 		elseif remaining == 2
# 			top_idx = last_right_idx + 1
# 			bottom_idx = last_right_idx + 2

# 			A[last_right_idx, top_idx] = 1
# 			A[top_idx, last_right_idx] = 1

# 			A[last_right_idx, bottom_idx] = 1
# 			A[bottom_idx, last_right_idx] = 1
# 		end
# 	end
# 	return A
# end

function triangles(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0.5, 0.5*sqrt(3))
    sites = vec([50 .*(a .* i .+ b .* j) for i=1:Na, j=1:Nb])

    graph = ProblemReductions.UnitDiskGraph(vec(sites), 55.0)
    g = SimpleGraph(graph)
    return g
end

function squares(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0, 1)
    sites = vec([50 .*(a .* i .+ b .* j) for i=1:Na, j=1:Nb])

    graph = ProblemReductions.UnitDiskGraph(vec(sites), 50.0)
    g = SimpleGraph(graph)
    return g
end

function diamonds(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0, 1)
    sites = vec([50 .* (a .* (j % 2 == 0 ? 2*i-1 : 2*i) .+ b .* j) for i=1:Na, j=1:Nb])

    sites=vcat(sites, [50 .* (a .* (2*Na+1) .+b .*(j)) for j=2:2:Nb])

    graph = ProblemReductions.UnitDiskGraph(vec(sites), 50.0*√2)
    g = SimpleGraph(graph)
    return g
    
end
