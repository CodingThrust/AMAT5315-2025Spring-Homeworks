# Homework 8

1. (Computational complexity) Reduce the following circuit SAT (half adder) to a spin glass ground state problem.

    ![](halfadder.png)

2. (Spin dynamics - optional) Use the spin dynamics simulation to find the ground state of the above spin glass problem. Fix the output is $S=0, C=1$, and read out the input spin configuration.

3. (Challenge: Simulated Annealing) Optimize the simulated annealing scheduler for tensor network contraction. We implemented multiple algorithms in [OMEinsumContractionOrders.jl](https://github.com/TensorBFS/OMEinsumContractionOrders.jl) to find the optimal contraction order.
The simulated annealing based one, `TreeSA`, is the most popular, but is slow. The challenge is to implement a better simulated annealing scheduler with at least 10x speedup and create a PR to merge it.
The relevant code to improve is here: https://github.com/TensorBFS/OMEinsumContractionOrders.jl/blob/523434dcd671bd35ee31da518b336580c5a7822c/src/treesa.jl#L251-L293 .
    
    The improvement must be systematic with a proper benchmark in different settings. It is recommended to check this paper for some inspiration on how to design an adaptive simulated annealing scheduler[^Shojaee2021].
    The starting point is the tensor network in the folder `challenge`, with a known contraction space complexity of $52$[^Pan2021]. 
    The code is in the `main.jl` file. You can run it by typing the following command in a terminal:
    
    ```bash
    cd challenge
    julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.develop(url="https://github.com/TensorBFS/OMEinsumContractionOrders.jl.git")'
    julia --project=. main.jl
    [ Info: running circuit: sycamore_53_20_0
    ┌ Info: contraction complexity: Time complexity: 2^67.01176482416963
    │ Space complexity: 2^52.0
    └ Read-write complexity: 2^58.43881862537142, time cost: 85.032489934s
    ```
    Note: By completing this challenge, you will get a final score $A^+$.


[^Pan2021]: Pan, Feng, and Pan Zhang. "Simulating the Sycamore quantum supremacy circuits." arXiv preprint arXiv:2103.03074 (2021).
[^Shojaee2021]: Shojaee Ghandeshtani, K., Mashhadi, H.R., 2021. An entropy-based self-adaptive simulated annealing. Engineering with Computers 37, 1329–1355. https://doi.org/10.1007/s00366-019-00887-x
4. (Challenge: Problem reduction) Show elementary cellular automata rule 54 is universal. It is well known that the rule 110 is universal. Rule 54 is also believed to be universal, but no one proved it yet. Ref: https://mathworld.wolfram.com/Rule54.html
    Hint: through reduction. If you can use rule 54 to simulate rule 110, then rule 54 is universal.
