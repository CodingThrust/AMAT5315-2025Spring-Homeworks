1.
```
[10, 29, 56, 90, 130, 175, 224, 276, 330, 385, 330, 276, 224, 175, 130, 90, 56, 29, 10]
```
2.
```
The number of Flops for Householder reflection algorithm for a 1000x1000 matrix is approximately: 1.3333333333333335e9
The number of Flops for Gram - Schmidt algorithm for a 1000x1000 matrix is approximately: 2000000000
The Householder reflection algorithm is faster than the Gram - Schmidt algorithm.

```

3.
```
Original function (Julia loops):

  3.232 s (5870249 allocations: 10.10 GiB)
([1.0 0.0 … 0.0 0.0; 0.0 1.0 … 0.0 0.0; … ; 0.0 -0.0 … 1.0 0.0; 0.0 -0.0 … 0.0 1.0], [3.22996780814181 0.048847832045425414 … -0.347170514593713 1.0188971925238683; 0.0 -3.376783700878571 … 0.4936739279146613 0.41811273168602564; … ; 0.0 0.0 … 11.55022685121742 -12.206922062796835; 0.0 0.0 … 0.0 0.11172820130212413], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  991, 992, 993, 994, 995, 996, 997, 998, 999, 1000])


Optimized BLAS function:

  44.048 ms (2756 allocations: 11.55 MiB)
([1.0 0.0 … 0.0 0.0; 0.0 1.0 … 0.0 0.0; … ; 0.0 -0.0 … 1.0 0.0; 0.0 -0.0 … NaN 1.0], [-5.600561200683255e144 -7.3983726954789156e22 … NaN NaN; 0.0 2.0325272016352583e22 … NaN NaN; … ; 0.0 0.0 … NaN NaN; 0.0 0.0 … 0.0 NaN], [1, 2, 3, 4, 5, 6, 7, 782, 766, 10  …  991, 992, 993, 994, 995, 996, 997, 998, 999, 1000])

from 3.232 s to 44.048 ms
```

4.
```
using Test
using LinearAlgebra

function back_substitution(U::AbstractMatrix, b::AbstractVector)
    n = size(U, 1)
    x = zeros(n)
    x[n] = b[n] / U[n, n]
    for i = n - 1:-1:1
        x[i] = (b[i] - dot(U[i, i + 1:n], x[i + 1:n])) / U[i, i]
    end
    return x
end

@testset "Back-substitution" begin
    U = [1 2 3;
         0 4 5;
         0 0 6]
    b = [7, 8, 9]
    x = back_substitution(U, b)
    @test x ≈ [2.25, 0.125, 1.5]
end
```
```
back_substitution (generic function with 1 method)

Test Summary:     | Pass  Total  Time
Back-substitution |    1      1  0.6s
Test.DefaultTestSet("Back-substitution", Any[], 1, false, false, true, 1.747584447508757e9, 1.74758444810884e9, false, "/root/projects/AMAT5315-2025Spring-Homeworks/hw5/xiexuanzhang/hw5.jl")```
