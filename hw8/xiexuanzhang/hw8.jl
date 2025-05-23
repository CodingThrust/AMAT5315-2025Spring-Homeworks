using Random

function half_adder_sat(A, B)
    S = A ⊻ B  
    C = A & B    
    return S, C
end

function energy(A, B, S, C)
    E = 0
    if A == 0 && B == 0 && S == 1
        E += 1
    elseif A == 0 && B == 1 && S == 0 && C == 1
        E += 1
    elseif A == 1 && B == 0 && S == 1 && C == 1
        E += 1
    elseif A == 1 && B == 1 && S == 0
        E += 1
    end
    return E
end

# 模拟退火算法
function simulated_annealing()
    T = 1.0 
    T_min = 1e-3 
    alpha = 0.9
    max_iter = 1000  

    A = rand(Bool)
    B = rand(Bool)
    S = rand(Bool)
    C = rand(Bool)
    E_current = energy(A, B, S, C)

    for iter in 1:max_iter
        A_new = rand(Bool)
        B_new = rand(Bool)
        S_new = A_new ⊻ B_new
        C_new = A_new & B_new
        E_new = energy(A_new, B_new, S_new, C_new)

        if E_new < E_current || exp((E_current - E_new) / T) > rand()
            A, B, S, C = A_new, B_new, S_new, C_new
            E_current = E_new
        end

        T = T * alpha
        if T < T_min
            break
        end
    end

    return A, B, S, C
end

function main()
    A, B, S, C = simulated_annealing()
    println("A: ", A, " B: ", B, " S: ", S, " C: ", C)
end

main()