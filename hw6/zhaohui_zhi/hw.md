# Homework by Zhaohui Zhi

Mainly [refer to](./main.jl)
1 . 
```julia
    rowindices=[3,1,1,4,5]
colindices=[1,2,3,3,4]
data=[0.799,0.942,0.848,0.164,0.637]
```
2. No connected component, because no eigenvalues such as 0 in machine precision.
```julia
vals = vals = [3.3695840458420237e-15, 0.17173162534019842, 0.17216583440833988, 0.17267946797710076, 0.17299787525912835]
```
3. Refer to the [sourcecode](./restarting_lanczos.jl), and test [here](./test.jl)