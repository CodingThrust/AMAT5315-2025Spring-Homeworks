1. (Computational complexity) Reduce the following circuit SAT (half adder) to a spin glass ground state problem.

    Identifying the coefficients:
    *   **Bias terms (fields $h_i$):**
        $-h_A = -2 \implies h_A = 2$
        $-h_B = -2 \implies h_B = 2$
        $-h_C = +2 \implies h_C = -2$
        $-h_S = -1 \implies h_S = 1$
    *   **Coupling terms ($J_{ij}$):**
        $-J_{AB} = 0 \implies J_{AB} = 0$ (The $s_As_B$ terms cancelled out)
        $-J_{AC} = -2 \implies J_{AC} = 2$
        $-J_{BC} = -2 \implies J_{BC} = 2$
        $-J_{AS} = -1 \implies J_{AS} = 1$
        $-J_{BS} = -1 \implies J_{BS} = 1$
        $-J_{CS} = 0 \implies J_{CS} = 0$
    *   **Constant offset:** $E_0 = 3$. This can be omitted if only the ground state *configuration* is sought, as it doesn't change which configuration is lowest in energy.

    The spin glass problem is to find the configuration of spins $(s_A, s_B, s_S, s_C)$ that minimizes:
    $H = -2s_A - 2s_B + 2s_C - s_S - 2s_A s_C - 2s_B s_C - s_A s_S - s_B s_S (+ 3)$.

