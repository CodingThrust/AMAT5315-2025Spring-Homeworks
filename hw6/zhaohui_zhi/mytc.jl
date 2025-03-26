using LinearAlgebra

function toric_code_strings(m::Int, n::Int)
	li = LinearIndices((m, n))
	bottom(i, j) = li[mod1(i, m), mod1(j, n)] + m * n
	right(i, j) = li[mod1(i, m), mod1(j, n)]
	xstrings = Vector{Int}[]
	zstrings = Vector{Int}[]
	for i=1:m, j=1:n
		# face center
		push!(xstrings, [bottom(i, j-1), right(i, j), bottom(i, j), right(i-1, j)])
		# cross
		push!(zstrings, [right(i, j), bottom(i, j), right(i, j+1), bottom(i+1, j)])
	end
	return xstrings, zstrings
end

function tensor(arg...)
	return reduce(kron, arg)
end

function tc_hamiltonian(m::Int, n::Int)
	xstrings, zstrings = toric_code_strings(m, n)
	X= [0 1; 1 0]
	Z= [1 0; 0 -1]
	Id= [1 0; 0 1]
	l=2*m*n
	H=zeros(Int64, 2^l, 2^l)
	for i in xstrings
		cup=fill(Id, l)
		for j in i
			cup[j]=X
		end
		H+=tensor(cup...)
	end

	for i in zstrings
		cap=fill(Id, l)
		for j in i
			cap[j]=Z
		end
		H+=tensor(cap...)
	end
	return H
end