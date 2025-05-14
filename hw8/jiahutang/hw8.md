1. (Computational complexity) Reduce the following circuit SAT (half adder) to a spin glass ground state problem.
    A half-adder has two inputs (A, B) and two outputs: Sum (S) and Carry (C).
    The Boolean logic is:
    *   S = A XOR B
    *   C = A AND B

    Its truth table:
    | A | B | S | C |
    |---|---|---|---|
    | 0 | 0 | 0 | 0 |
    | 0 | 1 | 1 | 0 |
    | 1 | 0 | 1 | 0 |
    | 1 | 1 | 0 | 1 |


    The spin glass problem is to find the configuration of spins $(s_A, s_B, s_S, s_C)$ that minimizes:

  
    $H_{total} = -3 s_A s_B s_S + (3/4)s_A s_B - (3/2)s_A s_C - (3/2)s_B s_C + (3/4)s_A + (3/4)$

    Set S = 1

    | A | B | S | C | `s_A` | `s_B` | `s_S` | `s_C` | `H_total` (SAT: S=1) | SAT Met? |
    |---|---|---|---|-------|-------|-------|-------|----------------------|----------|
    | 0 | 0 | 0 | 0 |  +1   |  +1   |  +1   |  +1   |          1           |    No    |
    | 0 | 1 | 1 | 0 |  +1   |  -1   |  -1   |  +1   |         -1           |   Yes    |
    | 1 | 0 | 1 | 0 |  -1   |  +1   |  -1   |  +1   |         -1           |   Yes    |
    | 1 | 1 | 0 | 1 |  -1   |  -1   |  +1   |  -1   |          1           |    No    |

2. (Spin dynamics - optional) Use the spin dynamics simulation to find the ground state of the above spin glass problem. Fix the output is $S=0, C=1$, and read out the input spin configuration.

    Code in 'hw8-2.jl'
    Output:
    ```box
    [ Info: Setting up 5-spin system for half-adder with fixed outputs S=0 (sS=+1), C=1 (sC=-1)...
    [ Info: Initialized spin system with 5 spins and 6 edges.
    [ Info: Edges: Graphs.SimpleGraphs.SimpleEdge{Int64}[Edge 1 => 2, Edge 1 => 3, Edge 1 => 5, Edge 2 => 3, Edge 2 => 5, Edge 4 => 5]
    [ Info: Couplings: [1.5, -1.5, -1.5, -1.5, -1.5, -3.0]
    [ Info: External Fields (z-comp): [1.5, 1.5, -101.5, 100.0, -1.5]
    [ Info: Initial spin states (z-comp): [-1.0, 1.0, -1.0, 1.0, -1.0]
    [ Info: Running simulation for 30000 steps with dt=0.01, alpha=0.1...
    [ Info: Simulation complete.
    --- Results ---
    Final spin vectors (raw 3D vectors, z-component shown):
    s_A_vec_z: -1.0000000000015823
    s_B_vec_z: 1.0000000000045015
    s_C_vec_z: -0.999999999998473 (Target C=1 => s_C=-1)
    s_S_vec_z: 1.0000000000015516 (Target S=0 => s_S=+1)
    s_X_vec_z: -1.0000000000010207
    Final Ising spins (sign of z-components):
    s_A: -1.0
    s_B: 1.0
    s_C: -1.0 (Target -1)
    s_S: 1.0 (Target +1)
    s_X: -1.0 (Should be s_A*s_B = -1.0)
    Inferred Boolean inputs (A, B):
    A: 1
    B: 0
    Final Boolean outputs (S, C) for verification:
    S_final: 0 (Target 0)
    C_final: 1 (Target 1)

    --- Analytical Expectation ---
    For S=0, C=1:
    Inputs A=1 (s_A=-1), B=1 (s_B=-1)
    Outputs s_C=-1, s_S=+1
    Auxiliary s_X = s_A*s_B = (-1)*(-1) = +1
    true
    ```