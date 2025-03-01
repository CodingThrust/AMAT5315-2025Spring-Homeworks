1. (1)3.0ₜ; 

   (2)4.0ₜ;  
   
   (3)0.0ₜ;  
   
   (4)-Infₜ

2. type: Tropical{Float64}; 

   supertype: AbstractSemiring

3. abstract type

4. concrete type

5. ```julia
    A = rand(Tropical{Float64}, 100, 100)
    B = rand(Tropical{Float64}, 100, 100)
    C = A * B   
    @time C = A * B
    > 0.001182 seconds
    @profile for i in 1:100; C = A * B ;end
    Profile.print(format=:flat, mincount=10)
    > Count  Overhead File                                      Line Function
 =====  ======== ====                                      ==== ========
    79        78 @Base/array.jl                             994 setindex!
    39         0 @Base/array.jl                             372 similar
    39         0 @Base/boot.jl                              582 Array
    39         0 @Base/boot.jl                              592 Array
    39        39 @Base/boot.jl                              516 GenericMemory
   133         0 @Base/boot.jl                              430 eval
    39         0 @Base/boot.jl                              535 new_as_memoryref
   133         0 @Base/essentials.jl                       1055 #invokelatest#2
   133         0 @Base/essentials.jl                       1055 invokelatest(::Any, ::Any, ::Vararg{Any}; kwargs::Base.Pairs{Symbol, Union{}…
   133         0 @Base/essentials.jl                       1052 invokelatest(::Any)
   133         0 @Base/loading.jl                          2734 include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, f…
   133         0 @Base/logging/logging.jl                   632 with_logger
   133         0 @Base/logging/logging.jl                   522 with_logstate(f::VSCodeServer.var"#67#72"{Bool, Bool, Bool, Module, String, …
    85         0 @Base/simdloop.jl                           77 macro expansion
   133         0 @LinearAlgebra/src/matmul.jl               114 *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
    93         0 @LinearAlgebra/src/matmul.jl               895 _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64…
    94         0 @LinearAlgebra/src/matmul.jl               287 _mul!
    94         0 @LinearAlgebra/src/matmul.jl               868 generic_matmatmul!
    85         0 @LinearAlgebra/src/matmul.jl               896 macro expansion
    39         0 @LinearAlgebra/src/matmul.jl               117 matprod_dest
    94         0 @LinearAlgebra/src/matmul.jl               253 mul!
    94         0 @LinearAlgebra/src/matmul.jl               285 mul!
   133         0 @Profile/src/Profile.jl                     59 macro expansion
   133         0 @VSCodeServer/src/eval.jl                   34 (::VSCodeServer.var"#64#65")()
   133         0 @VSCodeServer/src/eval.jl                  263 (::VSCodeServer.var"#66#71"{VSCodeServer.ReplRunCodeRequestParams})()
   133         0 @VSCodeServer/src/eval.jl                  150 #67
   133         0 @VSCodeServer/src/eval.jl                  179 (::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String, Int64, Int64, …
   133         0 @VSCodeServer/src/eval.jl                  181 (::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String, Int64, Int64, …
   133         0 @VSCodeServer/src/eval.jl                  271 inlineeval(m::Module, code::String, code_line::Int64, code_column::Int64, fi…
   133         0 @VSCodeServer/src/eval.jl                  268 kwcall(::@NamedTuple{softscope::Bool}, ::typeof(VSCodeServer.inlineeval), m:…
   133         0 @VSCodeServer/src/repl.jl                   38 hideprompt(f::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String, Int…
   133         0 @VSCodeServer/src/repl.jl                  276 withpath(f::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String, Int64…
   133         0 @TropicalNumbers/src/tropical_maxplus.jl    93 macro expansion
   133         0 @TropicalNumbers/src/tropical_maxplus.jl    93 top-level scope
Total snapshots: 135. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
   ```

   From the profile, we can see that the multiplication and addition operation occupy the main runtime, which is the bottleneck.