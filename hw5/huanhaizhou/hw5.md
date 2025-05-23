2. (Householder reflection) Count the Flops of the Householder reflection algorithm when applied to a matrix $A$ with $1000$ rows and $1000$ columns. Compare it with the Gram-Schmidt algorithm.

    For an $m \times n$ matrix $A$, the number of flops of the Householder reflection algorithm is about $2 m n^2 - \frac{2}{3} n^3$ and that of the Gram-Schmidt algorithm is $2mn^2$.

    For a $1000\times1000$ instance, the number of flops are respectively about $1.333\times 10^9$ and $2\times10^9$, so the Householder reflection algorithm is faster than the Gram-Schmidt algorithm.