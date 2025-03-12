# Homework4 
## 1.Condition number
### (a)
```julia
julia> using LinearAlgebra

julia> A = [10e10 0; 0 10e-10]
2×2 Matrix{Float64}:
 1.0e11  0.0
 0.0     1.0e-9

julia> condition_number = cond(A)
1.0e20
```
Compared to 1, A is an **ill-condition** matrix.
### (b)
```julia
julia> B = [10e10 0; 0 10e10]
2×2 Matrix{Float64}:
 1.0e11  0.0
 0.0     1.0e11

julia> condition_number = cond(B)
1.0
```
Compared to 1, B is a **well-condition** matrix.
### (c)
```julia
julia> C = [10e-10 0; 0 10e-10]
2×2 Matrix{Float64}:
 1.0e-9  0.0
 0.0     1.0e-9
 
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
julia> A, b = [2 3 -2; 3 2 3; 4 -3 2; 1 2 3; -1 2 3], [1, 2, 3, 4, 5]
([2 3 -2; 3 2 3; … ; 1 2 3; -1 2 3], [1, 2, 3, 4, 5])
julia> x = A \ b 
3-element Vector{Float64}:
 0.23076923076923084
 0.3510848126232741
 0.911242603550296
```

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
using CairoMakie
using SpringSystem
using SpringSystem: eigenmodes, eigensystem, nv
using LinearAlgebra
using Graphs

function revised_spring_chain(offsets::Vector{<:Real}, stiffness::Real, masses::Vector{<:Real}; periodic::Bool=false)
    n = length(offsets)
    
    if length(masses) != n
        error("The length of the masses vector must match the number of particles.")
    end
    
    r = [SpringSystem.Point((i * 1.0, 0.0)) for i in 0:n-1]  
    dr = [SpringSystem.Point((Float64(offset), 0.0)) for offset in offsets]  
    v = fill(SpringSystem.Point((0.0, 0.0)), n)  
    topology = path_graph(n)  
    if periodic
        add_edge!(topology, n, 1)  
    end
    return SpringModel(r, dr, v, topology, fill(stiffness, n), masses)
end

function run_spring_chain(; C = 3.0, M = [i % 2 == 0 ? 2.0 : 1.0 for i in 1:21], L = 21, u0 = 0.2 * randn(L))
    spring = revised_spring_chain(u0, C, M; periodic=false)

    @info """Setup spring chain model:
    - mass = $M
    - stiffness = $C
    - length of chain = $L
    """
    @info """Simulating with leapfrog symplectic integrator:
    - dt = 0.1
    - number of steps = 500
    """
    simulated = leapfrog_simulation(spring; dt=0.1, nsteps=500)
    @info """Solving the spring system exactly with eigenmodes"""
    exact = waveat(eigenmodes(eigensystem(spring)), u0, 0.1 * (0:500))

    return simulated, exact
end

simulated, exact = run_spring_chain()
modes = eigenmodes(eigensystem(simulated[1].sys))
frequencies = modes.frequency
println("Eigenfrequencies: ", sort(frequencies))
```
```julia
Eigenfrequencies: [9.424321830774485e-8, 0.1830505977171767, 0.5162975549846789, 0.5450627452805287, 0.8948990918033847, 1.0210618757470242, 1.2247448713915898, 1.5030173614591409, 1.5272318743828845, 1.7956030409751693, 1.9513979229776885, 2.023863402776775, 2.206914000493948, 2.340665786255694, 2.356187479484911, 2.4221309661862676, 2.708343701183048, 3.0000000000000004, 3.224641256167724, 3.377249355231934, 3.454415284436828]
```