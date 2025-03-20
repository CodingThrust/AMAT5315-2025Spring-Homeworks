```
1.
i. The OMEinsum.jl package is licensed under the MIT License. As a user, you are allowed to use, copy, modify, and distribute the source code, including your modifications, provided that you retain the original MIT License and copyright notice in all copies or substantial portions of the Software. However, you cannot hold the authors or contributors liable for any issues that arise from using the software, and you should not use the name of the project or its contributors to promote derived products without permission. The limitations include Liability and Warranty.

ii. ChainRules at version 1.2 is compatible with OMEinsum. it's advanced to the compatible version 1.

iii. 89%
```

```
2. https://github.com/xiexuanzhang/MyFirstPackage.jl
```

```
3.
i. fib(n) = n <= 2 ? 1 : fib(n - 1) + fib(n - 2)` O(2^n)
```
It's O(2^n).
```
ii. julia> function fib_while(n)
           a, b = 1, 1
           for i in 3:n
               a, b = b, a + b
           end
           return b
       end
    O(n)
```

It's O(n).

4. 
```
a = [0 1 1 0 0;
     1 0 1 1 0;
     1 1 0 0 1;
     0 1 0 0 1;
     0 0 1 1 0]
```