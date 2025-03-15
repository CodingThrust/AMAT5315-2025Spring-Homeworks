# Homework 5

1. (Fourier transform) Evaluate the multiplication of two polynomials using the `FFTW` package in $O(n \log n)$ time, where $n$ is the degree of the polynomial.
   - $$p(x) = 1 + 2x + 3x^2 + 4x^3 + 5x^4 + 6x^5 + 7x^6 + 8x^7 + 9x^8 + 10x^9$$
   - $$q(x) = 10 + 9x + 8x^2 + 7x^3 + 6x^4 + 5x^5 + 4x^6 + 3x^7 + 2x^8 + x^9$$

2. (Householder reflection) Count the Flops of the Householder reflection algorithm when applied to a matrix $A$ with $1000$ rows and $1000$ columns. Compare it with the Gram-Schmidt algorithm.

3. (BLAS) Improve the `lufact_pivot!` function in ScientificComputingDemos/SimpleLinearAlgebra repository by using the BLAS level 1 routine `blascopy!` and `axpy!`. Benchmark the performance of the original algorithm and the improved one.

4. (Optional - Back-substitution) Back-substitution is for solving the upper triangular system. Please implement the back-substitution algorithm and verify the correctness of the algorithm by solving the following linear system.
```math
\begin{align}U x = b\\
U = \begin{pmatrix}
1 & 2 & 3 \\
0 & 4 & 5 \\
0 & 0 & 6
\end{pmatrix}
b = \begin{pmatrix}
7 \\ 8 \\ 9
\end{pmatrix}\end{align}
```math
   
