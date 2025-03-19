using Optim,Plots,LinearAlgebra
# 1. 
````
(a) ill-conditioned
(b) well-conditioned
(c) well-conditioned
(d) ill-conditioned
```

# 2.
A = [2.0 3 -2 0 0;
0 2 3 0 3;
4 0 2 -3 0;
1 2 3 0 0;
0 2 3 -1 0;
]
b = collect(1:5)
x = A\b

#=
5-element Vector{Float64}:
 -0.21505376344086
  0.9784946236559139
  0.7526881720430109
 -0.7849462365591394
 -0.7383512544802867
=#


# 3. 

years = collect(Float64,0:31)
pop = [2374,2250,2113,2120,2098,2052,2057,2028,1934,1827,1765,1696,1641,
1594,1588,1612,1581,1591,1604,1587,1588,1600,1800,1640,1687,1655,1786,1723,
1523,1465,1200,1062]



function loss(p)
    a,b,c,d = p
    yy = a .+ b*years + c * years .^ 2 + d * years .^ 3
    return sum(abs2.(yy - pop))
end

result = optimize(loss, zeros(4), NelderMead())
p = Optim.minimizer(result)

fit_curve(t) = p[1] + p[2]*t + p[3]*t^2 + p[4]*t^3


#画图
plot(years.+1990, fit_curve.(years), label="Population", xlabel="Year", ylabel="Population (×10⁴)", title="Chinese Population Prediction", linewidth=2, color=:red)
scatter!(years .+ 1990, pop, label="Data Points", color=:blue, marker=:circle, markersize=4)
#预测
fit_curve(34)
# 940.7110644490258


# 4. 

n = 21  
C = 3   
me = 1  
mo = 2 


M = zeros(n, n)
for i in 1:n
    if i % 2 == 0
        M[i, i] = me 
    else
        M[i, i] = mo 
    end
end

# 构建刚度矩阵 K
K = zeros(n, n)
for i in 1:n
    K[i, i] = 2C  
    if i < n
        K[i, i+1] = -C 
        K[i+1, i] = -C 
    end
end


K = K[2:end-1, 2:end-1]
M = M[2:end-1, 2:end-1]


eigenvalues = eigvals(K, M)


ω = sqrt.(eigenvalues)

#= 
ω: [0.22183908870561292, 0.44183416908789036, 0.6580667504532665, 0.868436490806754, 1.0704662693192701, 1.2609011236480128, 
1.4348179865245803, 1.5836045784361439, 1.691073111501517, 2.449489742783178, 2.477957169031898, 2.5479789126199774, 2.634634195774728, 
2.7221550941089268, 2.8025170768881473, 2.871553248929096, 2.92693494152977, 2.9672853868521663, 2.991786659961278]
 =#