using LinearAlgebra


A = [10^10 0; 0 10^(-10)]

cond_A = cond(A)

if cond_A < 100
    println("Matrix A is well-conditioned")
else
    println("Matrix A is ill-conditioned")
end


B = [10^10 0; 0 10^10]

cond_B = cond(B)

if cond_B < 100
    println("Matrix B is well-conditioned")
else
    println("Matrix B is ill-conditioned")
end


C = [10^(-10) 0; 0 10^(-10)]

cond_C = cond(C)

if cond_C < 100
    println("Matrix C is well-conditioned")
else
    println("Matrix C is ill-conditioned")
end


D = [1 2; 2 4]

cond_D = cond(D)

if cond_D < 100
    println("Matrix D is well-conditioned")
else
    println("Matrix D is ill-conditioned")
end


2.
using LinearAlgebra

A = [2 3 -2 0 0; 0 2 3 0 3; 4 0 2 -3 0; 1 2 3 0 0; 0 2 3 -1 0]

b = [1, 2, 3, 4, 5]
x = A \ b
println("x:")
println(x)

3.
using Makie, CairoMakie
using Polynomials
using Optim

# Load the raw data
years = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021]
population = [2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 1934, 1827, 1765, 1696, 1641, 1594, 1588, 1612, 1581, 1591, 1604, 1587, 1588, 1600, 1800, 1640, 1687, 1655, 1786, 1723, 1523, 1465, 1200, 1062]

# Shift the years data to make fitting easier
x = years .- 1990

# Define the cubic polynomial model
function polynomial_model(coeffs, x)
    a0, a1, a2, a3 = coeffs
    return a0 .+ a1 .* x .+ a2 .* x.^2 .+ a3 .* x.^3
end

# Define the objective function (mean squared error)
function objective_function(coeffs)
    y_pred = polynomial_model(coeffs, x)
    return sum((y_pred .- population).^2)
end

# Initial guess for coefficients
initial_coeffs = [0.5, 0.5, 0.5, 0.5]

# Optimize to find the best - fit coefficients
result = optimize(objective_function, initial_coeffs, BFGS())

# Get the optimized coefficients
optimized_coeffs = Optim.minimizer(result)

# Generate x values for plotting the fitted curve
x_fit = range(minimum(x), maximum(x), length = 300)
# Calculate the corresponding y values
y_fit = polynomial_model(optimized_coeffs, x_fit)

# Create a figure and axis for plotting
fig = Figure()
ax = Axis(fig[1, 1], xlabel = "Year (shifted)", ylabel = "Population (10^4)")
# Add scatter plot for the original data points
scatter!(ax, x, population, color = :blue, marker = :circle, markersize = 6, label = "Data Points")
# Add line plot for the fitted curve
lines!(ax, x_fit, y_fit, color = :red, label = "Fitted Cubic Polynomial")
# Add legend
axislegend(; position = :lt)
# Save the plot as 'fitting.png'
save("fitting.png", fig)

# Predict the population in 2024
year_2024 = 2024 - 1990
predicted_population = polynomial_model(optimized_coeffs, [year_2024])[1]
println("The predicted population in 2024 is: ", predicted_population)

4.
using LinearAlgebra

# Define system parameters
N = 21               # Number of particles in the chain
C = 3.0              # Spring constant between adjacent particles
m_e = 1.0            # Mass of particles at even positions
m_o = 2.0            # Mass of particles at odd positions

# Create mass array with alternating particle masses
masses = [isodd(i) ? m_o : m_e for i in 1:N]
# Construct diagonal mass matrix M
M = Diagonal(masses)

# Build tridiagonal stiffness matrix K
sub_diag = -C * ones(N - 1)    # Subdiagonal elements
diag = 2C * ones(N)           # Main diagonal elements
super_diag = -C * ones(N - 1)  # Superdiagonal elements
K = Tridiagonal(sub_diag, diag, super_diag)

# Solve generalized eigenvalue problem: K * v = λ * M * v
eigen_result = eigen(K, M)
eigenvalues = eigen_result.values

# Calculate eigenfrequencies: ω = √(λ)
eigenfrequencies = sqrt.(real(eigenvalues))

# Sort eigenfrequencies in ascending order
sorted_eigenfrequencies = sort(eigenfrequencies)

# Display results
println("Eigenfrequencies of the 1D chain:")
for (i, freq) in enumerate(sorted_eigenfrequencies)
    println("ω$i = $(round(freq, digits=4))")
end