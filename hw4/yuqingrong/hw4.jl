#1. (Condition number) 

#(a)ill
#(b)well
#(c)well
#(d)ill

# 2. (Solving linear equations)
using LinearAlgebra
A = [2.0 3 -2 0 0;
0 2 3 0 3;
4 0 2 -3 0;
1 2 3 0 0;
0 2 3 -1 0;
]
b = [1,2,3,4,5]
x = A\b
@show x
# => 5-element Vector{Float64}:
# -0.21505376344086
# 0.9784946236559139
# 0.7526881720430109
# -0.7849462365591394
# -0.7383512544802867

# 3. (Data fitting)

using Makie, CairoMakie
using Polynomials
using Optim

years = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021]
population = [2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 1934, 1827, 1765, 1696, 1641, 1594, 1588, 1612, 1581, 1591, 1604, 1587, 1588, 1600, 1800, 1640, 1687, 1655, 1786, 1723, 1523, 1465, 1200, 1062]
x = years .- 1990


function polynomial_model(coeffs, x)
    return coeffs[1] .+ coeffs[2] .* x .+ coeffs[3] .* x.^2 .+ coeffs[4] .* x.^3
end


function loss_function(coeffs)
    y_pred = polynomial_model(coeffs, x)
    return sum((y_pred .- population).^2)
end


initial_coeffs = [0.0, 0.0, 0.0, 0.0]

result = optimize(loss_function, initial_coeffs, LBFGS())

optimized_coeffs = Optim.minimizer(result)


x_fit = range(minimum(x), maximum(x), length=100)
y_fit = polynomial_model(optimized_coeffs, x_fit)

# plot
fig = Figure()
ax = Axis(fig[1, 1], xlabel="Year (shifted)", ylabel="Population (10^4)")
scatter!(ax, x, population, color=:blue, marker=:circle, markersize=10, label="Data")
lines!(ax, x_fit, y_fit, color=:red, label="Fitted Curve")
axislegend(; position=:rb)
fig  # preview
save("population_fit_optimized.png", fig)

# Predict population in 2024
year_2024 = 2024 - 1990
predicted_population = polynomial_model(optimized_coeffs, [year_2024])[1]
""" => 940.7111295920595 """

# 4. (Optional: Eigen-decomposition) 
N = 21  
C = 3   
m_e = 1 
m_o = 2


masses = [i % 2 == 0 ? m_e : m_o for i in 1:N]


D = zeros(N-2, N-2)
for i in 1:N-2
    D[i, i] = 2C / masses[i+1]  
    if i > 1
        D[i, i-1] = -C / masses[i+1]  
    end
    if i < N-2
        D[i, i+1] = -C / masses[i+1]  
    end
end


eigenvalues = eigvals(D)

eigenfrequencies = sqrt.(eigenvalues)
""" => [0.2218390887056129, 0.44183416908789, 0.6580667504532671, 0.8684364908067553, 1.0704662693192704, 
     1.2609011236480123, 1.4348179865245825, 1.583604578436145, 1.6910731115015185, 2.449489742783179, 
     2.477957169031898, 2.5479789126199783, 2.6346341957747286, 2.7221550941089268, 2.802517076888148, 
     2.8715532489290974, 2.9269349415297694, 2.967285386852167, 2.9917866599612783] """





