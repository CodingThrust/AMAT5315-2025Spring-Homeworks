# Homework

1. (Version number) Consider the following Julia package `OMEinsum.jl`: https://github.com/under-Peter/OMEinsum.jl, which is a package for optimizing tensor contractions. The package is registered in the General registry. Please answer the following questions by checking the `Project.toml` file of the package.
    1. Is `ChainRulesCore` at version 1.2 compatible with `OMEinsum`?
    2. If `ChainRulesCore` at version 2.0 is released, what should be done to make `OMEinsum` compatible with the new version of `ChainRulesCore`? Which GitHub Action is used to automate this process?
    3. If an author of `OMEinsum` fixed a bug, what should be done to make the new version of `OMEinsum` available to the public, and what is the correct version number of `OMEinsum` after the bug fix?
    4. If an author of `OMEinsum` changed an exported function, what is the correct version number of `OMEinsum` after the change?

2. (Unit tests and LICENSE) By checking the [GitHub repo of Yao](https://github.com/QuantumBFS/Yao.jl), answer the following questions:
    - What is the test coverage of Yao?
    - Is the `master` (the old name for `main`) branch of Yao passing all tests?
    - What is the LICENSE of Yao? If you are a user, what can you do and cannot do with Yao's source code?

3. (Create a package) Following the [guide](https://scfp.jinguo-group.science/chap1-julia/julia-release.html) in the lecture, create a Julia package named `MyFirstPackage.jl` under your own GitHub account:
    - write any function that you like,
    - write a test for it,
    - please make sure that the GitHub Action is working properly, and all tests are passed,
    - as a warning: please do **not** register your package to the General registry!

    Please submit the link to the GitHub repository of your package.

