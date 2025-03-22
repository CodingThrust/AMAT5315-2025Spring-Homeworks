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
vals = [-0.43430816231445546, 4.132323230426893e-5, 0.17238769102984586, 0.17255108710926395, 0.1729207846967728, 0.1729787184492682, 0.1732759402100831, 0.17363004622534534, 0.17375614561024902, 0.17439884738996286]
```
3. Refer to the [sourcecode](./restarting_lanczos.jl), and test [here](./test.jl)