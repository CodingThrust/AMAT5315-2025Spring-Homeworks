# Homework 4

1. (Condition number) Classify each of the following matrices as well-conditioned or ill-conditioned:

#### (a)
$$
A = \begin{pmatrix} 10^{10} & 0 \\ 0 & 10^{-10} \end{pmatrix}
$$
- **Condition Number**: $\kappa(A) = \frac{\lambda_{\text{max}}}{\lambda_{\text{min}}} = \frac{10^{10}}{10^{-10}} = 10^{20}$.
- **Classification**: **Ill-conditioned**.

---

#### (b)
$$
A = \begin{pmatrix} 10^{10} & 0 \\ 0 & 10^{10} \end{pmatrix}
$$
- **Condition Number**: $\kappa(A) = \frac{\lambda_{\text{max}}}{\lambda_{\text{min}}} = \frac{10^{10}}{10^{10}} = 1$.
- **Classification**: **Well-conditioned**.

---

#### (c)
$$
A = \begin{pmatrix} 10^{-10} & 0 \\ 0 & 10^{-10} \end{pmatrix}
$$
- **Condition Number**: $\kappa(A) = \frac{\lambda_{\text{max}}}{\lambda_{\text{min}}} = \frac{10^{-10}}{10^{-10}} = 1$.
- **Classification**: **Well-conditioned**.

---

#### (d)
$$
A = \begin{pmatrix} 1 & 2 \\ 2 & 4 \end{pmatrix}
$$
- **Eigenvalues**: $\lambda_1 = 5$, $\lambda_2 = 0$.
- **Condition Number**: $\kappa(A) = \infty$ (matrix is singular).
- **Classification**: **Ill-conditioned**.


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
answer:

Here is the Julia code:

```julia
# Define the coefficient matrix A
A = [2   3  -2   0   0;
     0   2   3   0   3;
     4   0   2  -3   0;
     1   2   3   0   0;
     0   2   3  -1   0]

# Define the right-hand side vector b
b = [1; 2; 3; 4; 5]

# Solve the system Ax = b
x = A \ b

# Display the solution
println("Solution: ", x)
```

```plaintext
Solution: [-0.21505376344086, 0.9784946236559139, 0.7526881720430109, -0.7849462365591394, -0.7383512544802867]
```


3. (Data fitting) Consider the following data set of the new-born population in China. The first column is the year and the second column is the population in 万 ($10^4$). Please use Julia to fit the data with a polynomial of degree 3, i.e., $y = a_0 + a_1 x + a_2 x^2 + a_3 x^3$. Plot the data and fitted curve, and predict population in 2024. Hint: when fitting data, shifting the $x$-axis may improve the result quality.

### Full Code
Here’s the complete code:

```julia
using Polynomials
using Makie, CairoMakie

# Data: Year and Population (in 10^4)
years = [1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999,
         2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
         2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
         2020, 2021]
population = [2374, 2250, 2113, 2120, 2098, 2052, 2057, 2028, 1934, 1827,
              1765, 1696, 1641, 1594, 1588, 1612, 1581, 1591, 1604, 1587,
              1588, 1600, 1800, 1640, 1687, 1655, 1786, 1723, 1523, 1465,
              1200, 1062]

# Shift the x-axis 
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
```

### Output

Fitted polynomial: 1683.61 - 2.79382*x + 0.720529*x^2 - 0.148115*x^3

Predicted population in 2024: 940.71 万

---

4. (Optional: Eigen-decomposition) Find the eigenfrequencies of a 1D chain with fixed boundary. The spring constant between the $i$-th and $(i+1)$-th particles is $C = 3$ and the mass of each particle is $m_e = 1$ on even sites and $m_o = 2$ on odd sites. The chain has $21$ particles.


```julia
using LinearAlgebra

# 参数设置
N = 21
C = 3.0
m_e = 1.0
m_o = 2.0

# 构造质量矩阵 M（对角矩阵，奇数位质量为2，偶数位为1）
masses = [isodd(i) ? m_o : m_e for i in 1:N]
M = diagm(masses)

# 构造刚度矩阵 K（三对角矩阵）
K = Tridiagonal(
    -C * ones(N-1),   # 次对角线（下）
     2C * ones(N),    # 主对角线
    -C * ones(N-1)    # 次对角线（上）
)

# 解广义特征值问题 K v = ω² M v
eigenvals = eigen(K, M).values

# 提取实部并计算特征频率（虚部应为零，忽略数值误差）
frequencies = sqrt.(real(eigenvals)) ./ (2π)

# 按升序排序
sorted_freq = sort(frequencies)

# 输出结果
println("前10个特征频率 (Hz)：")
for i in 1:10
    println("ωₖ = ", round(sorted_freq[i], digits=4))
end
```

### Output
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