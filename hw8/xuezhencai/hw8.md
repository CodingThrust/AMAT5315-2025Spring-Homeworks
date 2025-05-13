# Homework 8
## 1. Computational complexity
### answer
```julia
spin_vals = [0, 1] 
solutions = []

for x in spin_vals, y in spin_vals, a in spin_vals, s in spin_vals, c in spin_vals
    h1 = (a - x * y)^2
    h2 = (c - a)^2
    h3 = (s - (x + y - 2a))^2

    H = h1 + h2 + h3

    if H == 0
        push!(solutions, (x=x, y=y, s=s, c=c))
    end
end

println("===== Logic-Exact Half Adder Ground States =====")
foreach(println, solutions)
```
```julia
===== Logic-Exact Half Adder Ground States =====

(x = 0, y = 0, s = 0, c = 0)
(x = 0, y = 1, s = 1, c = 0)
(x = 1, y = 0, s = 1, c = 0)
(x = 1, y = 1, s = 0, c = 1)
```