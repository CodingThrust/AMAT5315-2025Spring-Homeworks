1. result = [10, 29, 56, 90, 130, 175, 224, 276, 330, 385, 330, 276, 224, 175, 130, 90, 56, 29, 10]
2. For a $m \times n$ matrix $A$, the Flops of the Householder reflection algorithm is about: $T_1 = 2 m \times n^2 - 2/3 \times n^3$. So for a $1000×1000$ matrix, the Flops is about $1.33\times 10^9$
While the Flops of the Gram-Schmidt algorithm is about $T_2 = 2 m \times n^2$, the Flops is about $2 \times 10 ^9$, $T_1 < T_2$, so the Householder reflection algorithm is faster than the Gram-Schmidt algorithm.

3. Performance of original lufact_pivot! :
203.726 μs (6 allocations: 79.14 KiB) (Intel 8458P)
128.084 μs (6 allocations: 157.25 KiB) (mba M3)
Performance of mylufact_pivot!
43.314 μs (6 allocations: 79.14 KiB) (Intel 8458P)
206.916 μs (194 allocations: 321.75 KiB) (mba M3) 
