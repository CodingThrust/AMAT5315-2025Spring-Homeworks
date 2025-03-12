using Polynomials
using Makie, CairoMakie
using Statistics  # Import the Statistics module to use `mean`

# Data: Year and Population (in 10^4)
years = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999,
         2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
         2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
         2020, 2021]
population = [2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 1934, 1827,
              1765, 1696, 1641, 1594, 1588, 1612, 1581, 1591, 1604, 1587,
              1588, 1600, 1800, 1640, 1687, 1655, 1786, 1723, 1523, 1465,
              1200, 1062]

# Shift the x-axis for better numerical stability
mean_year = mean(years)  # Center the data
shifted_years = years .- mean_year

# Fit a cubic polynomial to the shifted data
poly_fit = fit(Polynomial, shifted_years, population, 3)

# Display the coefficients of the fitted polynomial
println("Fitted polynomial: ", poly_fit)

# Generate points for the fitted curve
x_fine = range(minimum(shifted_years), maximum(shifted_years), length=100)
y_fine = poly_fit.(x_fine)

# Create the figure and axis
fig = Figure()
ax = Axis(fig[1, 1], xlabel="Year (shifted)", ylabel="Population (10^4)")
scatter!(ax, shifted_years, population, color=:blue, marker=:circle, markersize=20, label="Data")
lines!(ax, x_fine, y_fine, color=:red, label="Fitted Curve")
axislegend(; position=:rb)

# Save and preview the plot
save("fitting-data.png", fig)
fig

# Predict population in 2024
x_2024 = 2024 - mean_year
predicted_population_2024 = poly_fit(x_2024)

println("Predicted population in 2024: ", round(predicted_population_2024, digits=2), " 万")