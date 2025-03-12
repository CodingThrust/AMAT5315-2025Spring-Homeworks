# Homework3

## 1
### i
The license it uses is MIT License.

The permissions are Commercial use, Modification, Distribution and Private use.

The limitations are Liability and Warranty.

### ii
`ChainRulesCore` at version 1.2 is compatible.

In `project.toml` we have `ChainRulesCore = "1"`, which means it is compatible with version `[1.0.0, 2.0.0)`.

### iii
The test coverage is 89%.

## 2
https://github.com/benforgit/MyFirstPackage.jl

## 3
```julia
fib(n) = n <= 2 ? 1 : fib(n - 1) + fib(n - 2)
```

The time complexity is O(2^n).

```julia
function fib_while(n)
    a, b = 1, 1
    for i in 3:n
        a, b = b, a + b
    end
    return b
end
```

The time complexity is O(n).

## 4
```julia
5×5 SparseArrays.SparseMatrixCSC{Int64, Int64} with 12 stored entries:
 ⋅  1  1  ⋅  ⋅
 1  ⋅  1  1  ⋅
 1  1  ⋅  ⋅  1
 ⋅  1  ⋅  ⋅  1
 ⋅  ⋅  1  1  ⋅
```