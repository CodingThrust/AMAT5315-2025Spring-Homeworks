function back_substitution(U, b)
    n = size(U, 1)
    x = zeros(n)
    for i in n:-1:1
        sum_val = 0.0
        for j in i+1:n
            sum_val += U[i, j] * x[j]
        end
        x[i] = (b[i] - sum_val) / U[i, i]
    end
    return x
end