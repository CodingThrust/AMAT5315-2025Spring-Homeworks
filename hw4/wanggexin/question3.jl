import Pkg; Pkg.add("Makie")
import Pkg; Pkg.add("Polynomials")
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
println("predict_population：2024 $(round(Int, predicted_2024_population))wan")

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
save("/home/wang/WS/AMAT5315-2025Spring-Homeworks/hw4/wanggexin/fitting_data.png", fig)