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

3. 
using LinearAlgebra
using Makie, CairoMakie
using Polynomials

years = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 
         1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 
         2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 
         2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021]

populations = [2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 
               1934, 1827, 1765, 1696, 1641, 1594, 1588, 1612, 
               1581, 1591, 1604, 1587, 1588, 1600, 1800, 1640, 
               1687, 1655, 1786, 1723, 1523, 1465, 1200, 1062]

x = years .- 1990

A = hcat(ones(length(x)), x, x.^2, x.^3);

Q, R = qr(A)
y = R \ (Matrix(Q)' * populations)

time = vcat(years,[2022, 2023, 2024]).-1990

fig = Figure()
ax = Axis(fig[1, 1], xlabel="Time", ylabel="y")
scatter!(ax, x, populations, color=:blue, marker=:circle, markersize=20, label="data")
poly = Polynomial([y...])
fit = poly.(time)
lines!(ax, time, fit, color=:red, label="fitting")
axislegend(; position=:lb)
fig
save("hw_fitting.png", fig)

4.
using LinearAlgebra

C = 3
me = 1
mo = 2
N = 21 

M = Diagonal([if i % 2 == 0; me else mo end for i in 1:N])

K = zeros(N, N)
for i in 1:N-1
    K[i, i] += C
    K[i+1, i+1] += C
    K[i, i+1] -= C
    K[i+1, i] -= C
end

A = inv(M) * K

eigvals, eigvecs = eigen(A)

eigenfrequencies = sqrt.(eigvals)

println("Eigenfrequencies:")
println(eigenfrequencies)