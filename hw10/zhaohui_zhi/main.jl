using Pkg
Pkg.activate("./hw10/zhaohui_zhi")
Pkg.instantiate()
using FiniteDifferences, ForwardDiff, Enzyme, Optim, LinearAlgebra, Test
