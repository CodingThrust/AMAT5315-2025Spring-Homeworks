Problem 1
3.0ₜ
4.0ₜ
0.0ₜ
-Infₜ

----
Problem 2
Tropical{Float64}

----
Problem 3
An abstract type

----
Problem 4
An abstract type

----
Problem
```
BenchmarkTools.Trial: 10000 samples with 1 evaluation per sample.
 Range (min … max):  342.292 μs …   4.451 ms  ┊ GC (min … max): 0.00% … 90.82%
 Time  (median):     364.125 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   369.830 μs ± 119.760 μs  ┊ GC (mean ± σ):  1.20% ±  3.40%

     ▃  ▁  █     ▂█▃                                             
  ▄▂▃█▄▃█▅▄██▅▄▇▅███▇▅▄▄▃▄▃▃▃▃▃▃▂▃▂▂▂▂▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▃
  342 μs           Histogram: frequency by time          427 μs <

 Memory estimate: 109.31 KiB, allocs estimate: 6.
```

````
Overhead ╎ [+additional indent] Count File:Line; Function
=========================================================
   ╎337 @VSCodeServer/src/eval.jl:34; (::VSCodeServer.var"#64#65")()
   ╎ 337 @Base/essentials.jl:889; invokelatest(::Any)
   ╎  337 @Base/essentials.jl:892; #invokelatest#2
   ╎   337 @VSCodeServer/src/eval.jl:263; (::VSCodeServer.var"#66#71"{VSCodeServer.ReplRunCodeRequestParams})()
   ╎    337 @Base/logging.jl:627; with_logger
   ╎     337 @Base/logging.jl:515; with_logstate(f::Function, logstate::Any)
   ╎    ╎ 337 @VSCodeServer/src/eval.jl:150; (::VSCodeServer.var"#67#72"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})()
   ╎    ╎  337 @VSCodeServer/src/repl.jl:38; hideprompt(f::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})
   ╎    ╎   337 @VSCodeServer/src/eval.jl:179; (::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})()
   ╎    ╎    337 @VSCodeServer/src/repl.jl:276; withpath(f::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams}, path::St…
   ╎    ╎     337 @VSCodeServer/src/eval.jl:181; (::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})()
   ╎    ╎    ╎ 337 @VSCodeServer/src/eval.jl:268; kwcall(::@NamedTuple{softscope::Bool}, ::typeof(VSCodeServer.inlineeval), m::Module, code::String, code_line::Int64, code_column::Int64, fi…
   ╎    ╎    ╎  337 @VSCodeServer/src/eval.jl:271; inlineeval(m::Module, code::String, code_line::Int64, code_column::Int64, file::String; softscope::Bool)
   ╎    ╎    ╎   337 @Base/essentials.jl:889; invokelatest(::Any, ::Any, ::Vararg{Any})
   ╎    ╎    ╎    337 @Base/essentials.jl:892; invokelatest(::Any, ::Any, ::Vararg{Any}; kwargs::Base.Pairs{Symbol, Union{}, Tuple{}, @NamedTuple{}})
   ╎    ╎    ╎     337 @Base/loading.jl:2076; include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)
   ╎    ╎    ╎    ╎ 337 @Base/boot.jl:385; eval
   ╎    ╎    ╎    ╎  337 /Users/yui/projects/AMAT5315-2025Spring-Homeworks/hw2/Task.jl:94; top-level scope
   ╎    ╎    ╎    ╎   337 …-dot-10/usr/share/julia/stdlib/v1.10/Profile/src/Profile.jl:27; macro expansion
   ╎    ╎    ╎    ╎    337 …sers/yui/projects/AMAT5315-2025Spring-Homeworks/hw2/Task.jl:95; macro expansion
   ╎    ╎    ╎    ╎     337 …0/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:106; *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
   ╎    ╎    ╎    ╎    ╎ 41  @Base/array.jl:420; similar
   ╎    ╎    ╎    ╎    ╎  41  @Base/boot.jl:487; Array
 41╎    ╎    ╎    ╎    ╎   41  @Base/boot.jl:479; Array
   ╎    ╎    ╎    ╎    ╎ 296 …0/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:237; mul!
   ╎    ╎    ╎    ╎    ╎  296 …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:263; mul!
   ╎    ╎    ╎    ╎    ╎   296 …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:783; generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Float6…
   ╎    ╎    ╎    ╎    ╎    1   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:839; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
   ╎    ╎    ╎    ╎    ╎     1   @Base/array.jl:395; fill!
  1╎    ╎    ╎    ╎    ╎    ╎ 1   @Base/array.jl:1021; setindex!
   ╎    ╎    ╎    ╎    ╎    9   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:843; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
   ╎    ╎    ╎    ╎    ╎     9   …usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:670; copy_transpose!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{I…
   ╎    ╎    ╎    ╎    ╎    ╎ 7   …/share/julia/stdlib/v1.10/LinearAlgebra/src/transpose.jl:197; copy_transpose!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{…
  5╎    ╎    ╎    ╎    ╎    ╎  5   @Base/array.jl:1024; setindex!
  2╎    ╎    ╎    ╎    ╎    ╎  2   @Base/essentials.jl:14; getindex
   ╎    ╎    ╎    ╎    ╎    ╎ 1   …/share/julia/stdlib/v1.10/LinearAlgebra/src/transpose.jl:199; copy_transpose!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{…
  1╎    ╎    ╎    ╎    ╎    ╎  1   @Base/range.jl:901; iterate
  1╎    ╎    ╎    ╎    ╎    ╎ 1   …/share/julia/stdlib/v1.10/LinearAlgebra/src/transpose.jl:201; copy_transpose!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{…
   ╎    ╎    ╎    ╎    ╎    1   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:844; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
   ╎    ╎    ╎    ╎    ╎     1   …usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:660; copyto!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{Int64}, t…
   ╎    ╎    ╎    ╎    ╎    ╎ 1   @Base/abstractarray.jl:1165; copyto!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{Int64}, A::Matrix{Tropical{Float64}}, ir_s…
  1╎    ╎    ╎    ╎    ╎    ╎  1   @Base/essentials.jl:14; getindex
   ╎    ╎    ╎    ╎    ╎    248 …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:851; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
  1╎    ╎    ╎    ╎    ╎     1   @Base/essentials.jl:13; getindex
   ╎    ╎    ╎    ╎    ╎     245 …rs/yui/projects/AMAT5315-2025Spring-Homeworks/hw2/Task.jl:36; *
244╎    ╎    ╎    ╎    ╎    ╎ 245 @Base/float.jl:409; +
   ╎    ╎    ╎    ╎    ╎     2   …rs/yui/projects/AMAT5315-2025Spring-Homeworks/hw2/Task.jl:48; +
   ╎    ╎    ╎    ╎    ╎    ╎ 2   @Base/math.jl:906; max
  2╎    ╎    ╎    ╎    ╎    ╎  2   @Base/math.jl:889; llvm_max
  1╎    ╎    ╎    ╎    ╎    1   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:852; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
   ╎    ╎    ╎    ╎    ╎    14  …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:853; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
 14╎    ╎    ╎    ╎    ╎     14  @Base/array.jl:1021; setindex!
  6╎    ╎    ╎    ╎    ╎    6   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:854; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
   ╎    ╎    ╎    ╎    ╎    7   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:855; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
  7╎    ╎    ╎    ╎    ╎     7   @Base/range.jl:901; iterate
   ╎    ╎    ╎    ╎    ╎    1   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:856; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
  1╎    ╎    ╎    ╎    ╎     1   @Base/range.jl:901; iterate
   ╎    ╎    ╎    ╎    ╎    7   …/usr/share/julia/stdlib/v1.10/LinearAlgebra/src/matmul.jl:858; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, tA::Char, tB::Char, A::Matrix{Tropical{Floa…
   ╎    ╎    ╎    ╎    ╎     7   @Base/abstractarray.jl:1165; copyto!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{Int64}, A::Matrix{Tropical{Float64}}, ir_sr…
  6╎    ╎    ╎    ╎    ╎    ╎ 6   @Base/array.jl:1024; setindex!
  1╎    ╎    ╎    ╎    ╎    ╎ 1   @Base/essentials.jl:14; getindex
  1╎    ╎    ╎    ╎    ╎    1   …r/share/julia/stdlib/v1.10/LinearAlgebra/src/transpose.jl:202; copy_transpose!(B::Matrix{Tropical{Float64}}, ir_dest::UnitRange{Int64}, jr_dest::UnitRange{I…
Total snapshots: 339. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```