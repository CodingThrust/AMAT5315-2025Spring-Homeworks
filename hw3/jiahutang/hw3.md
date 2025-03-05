# Homework

1. (Version and CI/CD) Consider the following Julia package `OMEinsum.jl`: https://github.com/under-Peter/OMEinsum.jl, which is a package for optimizing tensor contractions. The package is registered in the General registry. Please answer the following questions:
    1. What is the LICENSE of OMEinsum? As a user, what can you do and cannot do with OMEinsum's source code?
    OMEinsum.jl is licensed under the MIT License (see the LICENSE file in the repository).
    What you CAN do :
    Use, modify, and distribute the source code for commercial or non-commercial purposes.
    Combine it with proprietary software.
    What you CANNOT do :
    Remove or alter the original copyright and license notices.
    Hold the authors liable for any damages arising from its use.

    2. Is `ChainRulesCore` at version 1.2 compatible with `OMEinsum` and why?
    ChainRulesCore@1.2 is compatible (no version conflicts).
    Reashon: 
    In file Project.toml :
        ChainRulesCore = "1"
    This means that OMEinsum.jl requires version 1.x of ChainRulesCore.

    3. What is the test coverage of OMEinsum?
        Codecov is 89%

2. (Create a package) Following the [guide](https://scfp.jinguo-group.science/chap1-julia/julia-release.html), complete the creation of `MyFirstPackage.jl` and upload the package to your own GitHub account. Requirements:
    - CI/CD setup properly, all tests pass and the test coverage is above 80%.
    - Please submit the GitHub link to the package, rather than the package files.
    - Note: In the guide, we implement the Lorenz attractor, you need to change it to the shortest path problem solver that we implemented in the class.
    - Warning: In the guide, the last step is to register the package to the General registry, please do **not** do that in your homework submission.

    https://github.com/CodePioneer42/MyFirstPackage.jl


3. (Big-$O$ notation) Consider the following Fibonacci function:
    ```julia
    fib(n) = n <= 2 ? 1 : fib(n - 1) + fib(n - 2)
    ```
    What is the time complexity of this function in Big-$O$ notation?
        Big-$O$(2^n)


    Consider the following alternative implementation with while loop:
    ```julia
    function fib_while(n)
        a, b = 1, 1
        for i in 3:n
            a, b = b, a + b
        end
        return b
    end
    ```
    What is the time complexity of this function in Big-$O$ notation?
        Big-$O$(n)

4. (Graph representation) What is the adjacency matrix of the following graph?
    0,1,1,0,0
    1,0,1,1,0
    1,1,0,0,1
    0,1,0,0,1
    0,0,1,1,0    
    
  