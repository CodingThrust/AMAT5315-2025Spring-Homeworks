# Homework 4

1. (Condition number) Classify each of the following matrices as well-conditioned or ill-conditioned:
```math
(a). ~~\left(\begin{matrix}10^{10} & 0\\ 0 & 10^{-10}\end{matrix}\right)
```
```math
(b). ~~\left(\begin{matrix}10^{10} & 0\\ 0 & 10^{10}\end{matrix}\right)
```
```math
(c). ~~\left(\begin{matrix}10^{-10} & 0\\ 0 & 10^{-10}\end{matrix}\right)
```
```math
(d). ~~\left(\begin{matrix}1 & 2\\ 2 & 4\end{matrix}\right)
```

2. (Solving linear equations) Let $x_1, x_2, \ldots, x_5$ be real numbers. Solve the following system of linear equations with Julia.
```math
\begin{align*}
2 x_1 + 3 x_2 - 2 x_3 &= 1, \\
3 x_5 + 2 x_2 + 3 x_3 &= 2, \\
4 x_1 - 3 x_4 + 2 x_3 &= 3, \\
x_1 + 2 x_2 + 3 x_3 &= 4, \\
-x_4 + 2 x_2 + 3 x_3 &= 5.
\end{align*}
```

2. (Data fitting) Consider the following data set of the new-born population in China. The first column is the year and the second column is the population in 万 ($10^4$). Please use Julia to fit the data with a polynomial of degree 3, i.e., $y = a_0 + a_1 x + a_2 x^2 + a_3 x^3$. Plot the data and predict the population in 2024.
    ```
    年份 (year)	人数 (population)
    1990	2374万	 
    1991	2250万	 
    1992	2113万	 
    1993	2120万	 
    1994	2098万
    1995	2052万	 
    1996	2057万	 
    1997	2028万	 
    1998	1934万
    1999	1827万	 
    2000	1765万	 
    2001	1696万	 
    2002	1641万	 
    2003	1594万
    2004	1588万	 
    2005	1612万	 
    2006	1581万	 
    2007	1591万	 
    2008	1604万	 
    2009	1587万	 
    2010	1588万
    2011	1600万	 
    2012	1800万
    2013	1640万	 
    2014	1687万	 
    2015	1655万	 
    2016	1786万
    2017	1723万	 
    2018	1523万	 
    2019	1465万	 
    2020	1200万	 
    2021	1062万
    ```

    NOTE: the following code are for data visualization.
    ```julia
    using Makie, CairoMakie
    using Polynomials

    time = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]
    y = [2.9, 2.7, 4.8, 5.3, 7.1, 7.6, 7.7, 7.6, 9.4, 9.0]

    fig = Figure()
    ax = Axis(fig[1, 1], xlabel="Time", ylabel="y")
    scatter!(ax, time, y, color=:blue, marker=:circle, markersize=20, label="data")
    poly = Polynomial([1.0, 2.0, 3.0])
    fit = poly.(time)
    lines!(ax, time, fit, color=:red, label="fitted")
    axislegend(; position=:rb)
    fig  # preview
    save("fitting-data2.png", fig)

    ```

3. (Eigen-decomposition) Find the eigenfrequencies of a 1D chain with fixed boundary. The spring constant between the $i$-th and $(i+1)$-th particles is $C = 3$ and the mass of each particle is $m_e = 1$ on even sites and $m_o = 2$ on odd sites. The chain has $21$ particles.

