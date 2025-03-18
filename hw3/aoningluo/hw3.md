```
1.
i. The OMEinsum.jl package is licensed under the MIT License. I can use it to modify the source code and distribute your modifications, and redistribute the software as long as you include the original MIT License and copyright notice. But I cannot hold the authors or contributors liable for any issues that arise from using the software, and use the name of the project or its contributors to promote derived products without permission.

ii. Yes, it's advanced to the compatible version 1.

iii. 89%
```

```
2. https://github.com/1aluo1/MyFirstPackage.jl.
```

```
3.
i. fib(n) = n <= 2 ? 1 : fib(n - 1) + fib(n - 2)` O(2^n)
ii. julia> function fib_while(n)
           a, b = 1, 1
           for i in 3:n
               a, b = b, a + b
           end
           return b
       end
    O(n)
````

```
4. 
a = [0 1 1 0 0;
     1 0 1 1 0;
     1 1 0 0 1;
     0 1 0 0 1;
     0 0 1 1 0]
```