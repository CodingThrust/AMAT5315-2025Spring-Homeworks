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

## Challenge: Boolean matrix factorization
Boolean matrix factorization plays a central role in using tropical tensor networks[^Liu2021] for solving SAT problems. However, it is also a well known hard problem[^Miettinen2020] due to its semiring structure. Its element-wise multiplication is replaced by the boolean operation $\land$ and addition is replaced by the boolean operation $\lor$.
In this challenge, you are requested to factorize a boolean matrix $M \in \mathbb{Z}_2^{1000 \times 1000}$:
  ```math
  A B = M
  ```
  where $A \in \mathbb{Z}_2^{1000 \times r}$ and $B \in \mathbb{Z}_2^{r \times 1000}$ are boolean matrices with a rank $r$ no larger than $120\%$ of the minimum rank. To test your implementation, you can switch to the `challenge` folder, start a Julia REPL with `julia --project`, instantiate the environment with `] instantiate`, and run the following code:
```julia
using TropicalNumbers, DelimitedFiles
M = TropicalAndOr.(readdlm("boolean_matrix.dat"))
A, B = boolean_matrix_factorization(M)  # implement this function

@test A * B == M
@test size(A, 2) <= 60
```
Hint: Two recommended approach to implement the missing function:
- Approach 1: By reducing it to an integer programming problem.
- Approach 2: Using the free energy machine[^Shen2025].

[^Miettinen2020]: Miettinen, Pauli, and Stefan Neumann. "Recent developments in boolean matrix factorization." arXiv preprint arXiv:2012.03127 (2020).
[^Shen2025]: Shen, Zi-Song, et al. "Free-energy machine for combinatorial optimization." Nature Computational Science (2025): 1-11.
[^Liu2021]: Liu, Jin-Guo, Lei Wang, and Pan Zhang. "Tropical tensor network for ground states of spin glasses." Physical Review Letters 126.9 (2021): 090506.
