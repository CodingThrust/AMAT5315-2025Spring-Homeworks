1. (1)3.0ₜ; 

   (2)4.0ₜ;  
   
   (3)0.0ₜ;  
   
   (4)-Infₜ

2. type: Tropical{Float64}; 

   supertype: AbstractSemiring

3. concrete type

4. concrete type

5. ```julia
    A = rand(Tropical{Float64}, 100, 100)
    B = rand(Tropical{Float64}, 100, 100)
    C = A * B   
    @time C = A * B
    @profile for i in 1:100; C = A * B ;end
    Profile.print(format=:flat, mincount=10)
   ```

   From the profile, we can see that the multiplication and addition operation occupy the main runtime, which is the bottleneck.