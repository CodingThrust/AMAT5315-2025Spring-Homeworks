# Homework 11

1. (Tensor network representation) Please write down the einsum notation for the following operations:
    - Matrix-vector multiplication: $A v$
    - Matrix trace: $\text{Tr}(A)$
    - Matrix transpose: $A^T$
    - Sum over the rows of a matrix: $\sum_i A_{ij}$
    - Multiplication of $5$ matrices in a row: $A_1 A_2 A_3 A_4 A_5$
    - Hadamard product: $A \circ B \Leftrightarrow C_{ij} = A_{ij} B_{ij}$

2. (Hidden Markov Model) Learn the transition matrix $A$ and emission matrix $B$ of an HMM for the following observation sequence with the Baum-Welch algorithm:
    $(0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, \dots)$

3. (Challenge) Factorize a $1000 \times 1000$ boolean matrix (@Zhongyi).
    - Method 1: By relaxing it to the semidefinite program.
    - Method 2: Using the free energy machine.