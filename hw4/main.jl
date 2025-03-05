using LinearAlgebra
using Makie, CairoMakie
using Polynomials

years = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999,
         2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
         2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
         2020, 2021]

populations = [2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 1934, 1827,
               1765, 1696, 1641, 1594, 1588, 1612, 1581, 1591, 1604, 1587,
               1588, 1600, 1800, 1640, 1687, 1655, 1786, 1723, 1523, 1465,
               1200, 1062]

# Shift x-axis
shifted_years = years .- 1990

A = hcat(ones(length(shifted_years)), shifted_years, shifted_years.^2, shifted_years.^3);

Q, R = qr(A)
x = R \ (Matrix(Q)' * populations)


time = vcat(years,[2022, 2023, 2024]).-1990


fig = Figure()
ax = Axis(fig[1, 1], xlabel="Time", ylabel="y")
scatter!(ax, shifted_years, populations, color=:blue, marker=:circle, markersize=20, label="data")
poly = Polynomial([x...])
fit = poly.(time)
lines!(ax, time, fit, color=:red, label="fitted")
axislegend(; position=:lb)
fig  # preview
save("fitting-data2.png", fig)

############################################
n =21
C = 3  # example size
Mat = diagm(1 => C.*ones(n-1)) +  diagm(-1 => C.*ones(n-1)) + diagm(0 => -2C.*ones(n))
Mat[1, 1] = -C
Mat[end, end] = -C
vals, vecs = eigen(Mat)
plot(vals)

@show vals