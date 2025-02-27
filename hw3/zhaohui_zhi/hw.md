# Homework 3 by Zhaohui Zhi

1. 
   1. The LICENSE of OMEinsum is MIT license。 I can use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the source code, but can not do such without copyright notice and this permission notice in all copies or substantial portions of the Software.
   2. Yes, because it's advanced to the compatible version `1`
   3. 89%
2. [MyFirsrPackage.jl](https://github.com/zzh-cycling/MyFirstPackage.jl)
3. 
    1. `fib(n) = n <= 2 ? 1 : fib(n - 1) + fib(n - 2)` $O(2^n)$
    2. 
    ```julia
      function fib_while(n)
               a, b = 1, 1
               for i in 3:n
                   a, b = b, a + b
               end
               return b
      end
   ```
      $O(n)$

4. ```a= [0 1 1 0 0; 1 0 1 1 0; 1 1 0 0 1; 0 1 0 0 1; 0 0 1 1 0]```