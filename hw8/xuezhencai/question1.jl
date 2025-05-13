spin_vals = [0, 1]  # 布尔变量取值
solutions = []

for x in spin_vals, y in spin_vals, a in spin_vals, s in spin_vals, c in spin_vals
    h1 = (a - x * y)^2
    h2 = (c - a)^2
    h3 = (s - (x + y - 2a))^2

    H = h1 + h2 + h3

    if H == 0
        push!(solutions, (x=x, y=y, s=s, c=c))
    end
end

println("===== Logic-Exact Half Adder Ground States =====")
foreach(println, solutions)
