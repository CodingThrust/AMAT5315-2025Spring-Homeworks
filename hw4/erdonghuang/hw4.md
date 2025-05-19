1.
```julia
using LinearAlgebra

A = [1e10 0; 0 1e-10]
B = [1e10 0; 0 1e10]
C = [1e-10 0; 0 1e-10]
D = [1 2; 2 4]

println("Condition number of A: ", cond(A)) 
Condition number of A: 1.0e20 (ill-conditioned)
println("Condition number of B: ", cond(B))
Condition number of B: 1.0 (well-conditioned)
println("Condition number of C: ", cond(C))
Condition number of C: 1.0 (well-conditioned)
println("Condition number of D: ", cond(D))
Condition number of C: 1.0 (ill-conditioned)

```

2.
```julia
using LinearAlgebra

A = [2.0 3 -2 0 0;
       0 2 3 0 3;
       4 0 2 -3 0;
       1 2 3 0 0;
       0 2 3 -1 0;
       ]


b = [1,2,3,4,5]


x = A\b


5-element Vector{Float64}:
 -0.21505376344086008
  0.978494623655914
  0.7526881720430109
 -0.7849462365591395
 -0.7383512544802866
 ```

3.
```julia
using Polynomials
years = collect(1990:2021)
population = [
    2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 1934, 1827,
    1765, 1696, 1641, 1594, 1588, 1612, 1581, 1591, 1604, 1587,
    1588, 1600, 1800, 1640, 1687, 1655, 1786, 1723, 1523, 1465,
    1200, 1062
]

x = years .- 2000
y = population


p = fit(x, y, 3)
Polynomial(1745.4108404763465 - 24.161098611251557*x + 3.164431067198847*x^2 - 0.1481152805949966*x^3)

println("Fitted polynomial: ", p)
Fitted polynomial: 1745.41 - 24.1611*x + 3.16443*x^2 - 0.148115*x^3


pred_2024 = p(24)
940.711129567612
```