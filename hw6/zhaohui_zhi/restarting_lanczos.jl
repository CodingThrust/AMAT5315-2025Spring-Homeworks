function lanczos(A, q1::AbstractVector{T}; abstol, maxiter) where T
    # Normalize the initial vector
    q1 = normalize(q1)
    
    # Initialize storage for basis vectors and tridiagonal matrix elements
    q = [q1]                # Orthonormal basis vectors
    α = [q1' * (A * q1)]    # Diagonal elements of tridiagonal matrix
    
    # Compute first residual: r₁ = Aq₁ - α₁q₁
    Aq1 = A * q1
    rk = Aq1 .- α[1] .* q1
    β = [norm(rk)]          # Off-diagonal elements of tridiagonal matrix
    
    # Main Lanczos iteration
    for k = 2:min(length(q1), maxiter)
        # Compute next basis vector: q_k = r_{k-1}/β_{k-1}
        push!(q, rk ./ β[k-1])
        
        # Compute A*q_k
        Aqk = A * q[k]
        
        # Compute diagonal element: α_k = q_k' * A * q_k
        push!(α, q[k]' * Aqk)
        
        # Compute residual: r_k = A*q_k - α_k*q_k - β_{k-1}*q_{k-1}
        # This enforces orthogonality to the previous two vectors
        rk = Aqk .- α[k] .* q[k] .- β[k-1] * q[k-1]
        
        # Compute the norm of the residual for the off-diagonal element
        nrk = norm(rk)
        
        # Check for convergence or maximum iterations
        if abs(nrk) < abstol || k == length(q1)
            break
        end
        
        push!(β, nrk)
    end
    
    # Return the tridiagonal matrix T and orthogonal matrix Q
    return SymTridiagonal(α, β), hcat(q...)
end

function restart(T::AbstractMatrix{ET}, Q::AbstractMatrix{ET}) where ET
    vals, U = eigen(Matrix(T))
    newq1=Q*U[:,1]
    return newq1
end

function restarting_lanczos(A, q1::AbstractVector{ET};iter) where ET
    T, Q = lanczos(A, q1; abstol=1e-6, maxiter=1000)
    for i in 1:iter
        q1 = restart(T, Q)
        T, Q = lanczos(A, q1; abstol=1e-6, maxiter=1000)
    end
    
    return T, Q  # 返回最后一次迭代的结果
end