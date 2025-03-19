1. 
(a) 
using LinearAlgebra
A = [10^10 0; 0 10^(-10)]
cond_A = cond(A)
println("Matrix A is ", cond_A < 100 ? "well-conditioned" : "ill-conditioned")

(b) 
B = [10^10 0; 0 10^10]
cond_B = cond(B)
println("Matrix B is ", cond_B < 100 ? "well-conditioned" : "ill-conditioned")

(c) 
C = [10^(-10) 0; 0 10^(-10)]
cond_C = cond(C)
println("Matrix C is ", cond_C < 100 ? "well-conditioned" : "ill-conditioned")

(d) 
D = [1 2; 2 4]
cond_D = cond(D)
println("Matrix D is ", cond_D < 100 ? "well-conditioned" : "ill-conditioned")

2. 
A = [2 3 -2 0 0; 0 2 3 0 3; 4 0 2 -3 0; 1 2 3 0 0;0 2 3 -1 0]
b = [1, 2, 3, 4, 5]
x = A \ b
