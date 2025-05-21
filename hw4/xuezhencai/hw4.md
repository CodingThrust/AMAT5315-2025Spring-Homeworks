# Homework4 
## 1.Condition number
### (a)
```julia
julia> using LinearAlgebra

julia> A = [1e10 0; 0 1e-10]
2×2 Matrix{Float64}:
 1.0e10  0.0
 0.0     1.0e-10

julia> condition_number = cond(A)
1.0e20
```
Compared to 1, A is an **ill-condition** matrix.
### (b)
```julia
julia> B = [1e10 0; 0 1e10]
2×2 Matrix{Float64}:
 1.0e10  0.0
 0.0     1.0e10

julia> condition_number = cond(B)
1.0
```
Compared to 1, B is a **well-condition** matrix.
### (c)
```julia
julia> C = [1e-10 0; 0 1e-10]
2×2 Matrix{Float64}:
 1.0e-10  0.0
 0.0      1.0e-10
 
julia> condition_number = cond(C)
1.0
```
Compared to 1, C is a **well-condition** matrix.
### (d)
```julia
julia> D = [1 2; 2 4]
2×2 Matrix{Int64}:
 1  2
 2  4
julia> condition_number = cond(D)
4.804857307547117e16
```
Compared to 1, D is an **ill-condition** matrix.

## 2. Solving Linear Equations
```julia
julia> A, b = [2 3 -2 0 0; 0 2 3 0 3; 4 0 2 -3 0; 1 2 3 0 0; 0 2 3 -1 0], [1, 2, 3, 4, 5]
([2 3 … 0 0; 0 2 … 0 3; … ; 1 2 … 0 0; 0 2 … -1 0], [1, 2, 3, 4, 5])
julia> x = A \ b 
5-element Vector{Float64}:
 -0.21505376344086
  0.9784946236559139
  0.7526881720430109
 -0.7849462365591394
 -0.7383512544802867

## 3. Data fitting
```julia
# define
t = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997,
     1998, 1999, 2000, 2001, 2002, 2003, 2004,
     2005, 2006, 2007, 2008, 2009, 2010, 2011, 
     2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021]
y = [2374, 2250, 2113, 2120, 2098, 2052, 2057,
     2028, 1934, 1827, 1765, 1696, 1641, 1594, 1588, 1612, 
     1581, 1591, 1604, 1587, 1588, 1600, 1800, 1640, 1687, 
     1655, 1786, 1723, 1523, 1465, 1200, 1062]

# shift
shift_t = t .- 1990
A = hcat(ones(length(shift_t)), shift_t, shift_t.^2, shift_t.^3)
x = (A' * A) \ (A' * y)

# prediction
function predict_population(year)
    shifted_year = year - 1990
    return x[1] + x[2]*shifted_year + x[3]*shifted_year^2 + x[4]*shifted_year^3
end
predicted_2024_population = predict_population(2024)

println("预测2024年的新生儿人口为$(round(predicted_2024_population))万")
```

```julia
预测2024年的新生儿人口为941.0万
```
To visulize the data and the prediction I change code
```julia
using Makie, CairoMakie
using Polynomials
using LinearAlgebra

# define
t = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997,
     1998, 1999, 2000, 2001, 2002, 2003, 2004,
     2005, 2006, 2007, 2008, 2009, 2010, 2011, 
     2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021]
y = [2374, 2250, 2113, 2120, 2098, 2052, 2057,
     2028, 1934, 1827, 1765, 1696, 1641, 1594, 1588, 1612, 
     1581, 1591, 1604, 1587, 1588, 1600, 1800, 1640, 1687, 
     1655, 1786, 1723, 1523, 1465, 1200, 1062]

# shift
shift_t = t .- 1990
A = hcat(ones(length(shift_t)), shift_t, shift_t.^2, shift_t.^3)
x = (A' * A) \ (A' * y)

# prediction
function predict_population(year)
    shifted_year = year - 1990
    return x[1] + x[2]*shifted_year + x[3]*shifted_year^2 + x[4]*shifted_year^3
end

predicted_2024_population = predict_population(2024)
println("预测2024年的新生儿人口为$(round(Int, predicted_2024_population))万")

# figure
plot_shift_t = minimum(shift_t):0.1:maximum(shift_t)
fit_values = [predict_population(year + 1990) for year in plot_shift_t]

fig = Figure()
ax = Axis(fig[1, 1], xlabel="Years since 1990", ylabel="Population (in 10^4)")
scatter!(ax, shift_t, y, color=:blue, marker=:circle, markersize=10, label="Data")
lines!(ax, plot_shift_t, fit_values, color=:red, linewidth=2, label="Fitted Curve")
axislegend(; position=:rb)
fig #preview 

# save
save("/hpc2hdd/home/xcai553/AMAT5315-2025Spring-Homeworks/hw4/xuezhencai/fitting_data.png", fig)
```

## 4.Optional
```julia
using LinearAlgebra

N = 21
C = 3.0
m_e = 1.0
m_o = 2.0

masses = [isodd(i) ? m_o : m_e for i in 1:N]
M = diagm(masses)

K = Tridiagonal(
    -C * ones(N-1),  
     2C * ones(N),   
    -C * ones(N-1)   
)

eigenvals = eigen(K, M).values

frequencies = sqrt.(real(eigenvals)) ./ (2π)

sorted_freq = sort(frequencies)

println("前10个特征频率 (Hz)：")
for i in 1:10
    println("ωₖ = ", round(sorted_freq[i], digits=4))
end
```
```julia
ωₖ = 0.0321
ωₖ = 0.064
ωₖ = 0.0954
ωₖ = 0.1262
ωₖ = 0.1559
ωₖ = 0.1844
ωₖ = 0.2111
ωₖ = 0.2353
ωₖ = 0.2557
ωₖ = 0.2702
```