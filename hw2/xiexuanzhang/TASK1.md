TASK 1
1. 
``` 
julia> Tropical(1.0) + Tropical(3.0)
3.0ₜ

julia> Tropical(1.0) * Tropical(3.0)
4.0ₜ

julia> one(Tropical{Float64})
0.0ₜ

julia> zero(Tropical{Float64})
-Infₜ
```
2. What is the type and supertype of Tropical(1.0)?
```
julia> typeof(Tropical(1.0))
Tropical{Float64}

julia> supertype(Tropical{Float64})
AbstractSemiring
```

3. Is Tropical a concrete type or an abstract type?
A: It is neither concrete type or an abstract type.
```
julia> isconcretetype(Tropical)
false

julia> isabstracttype(Tropical)
false
```
4. Is Tropical{Real} a concrete type or an abstract type?
A: It is a concrete type.
```
julia> isconcretetype(Tropical{Real})
true

julia> isabstracttype(Tropical{Real})
false
```
5.Benchmark and profile the performance of Tropical matrix multiplication:
```
julia> using Random

julia> using BenchmarkTools

julia> A = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
    0.675106533178092ₜ   0.13419495471912823ₜ    0.6151843348889162ₜ  …   0.6214080779346554ₜ    0.677149973788233ₜ    0.557941991460517ₜ
   0.9385283843355047ₜ    0.6292612251193195ₜ    0.5963757367129109ₜ     0.18782007190866212ₜ   0.7965778854542129ₜ    0.905287920472517ₜ
   0.8391649517288814ₜ   0.49051426013443145ₜ     0.767980333210885ₜ      0.2004648693662212ₜ   0.5057553030340955ₜ  0.11252043797615918ₜ
  0.21024568944135458ₜ  0.013127546349840924ₜ   0.00887388158144553ₜ      0.9706931819483912ₜ   0.5028981918739149ₜ   0.5758260746522912ₜ
                     ⋮                                                ⋱                                              
   0.5663914694701614ₜ    0.4497328578437879ₜ    0.5989673856787557ₜ     0.22962557136167516ₜ   0.5760659213267411ₜ   0.9232415343250704ₜ
 0.006662334911643808ₜ    0.1254626015432787ₜ    0.3798433143695358ₜ     0.07150409230561483ₜ   0.8857841862684341ₜ   0.8009695292532792ₜ
  0.09890562107697065ₜ    0.7588393707198617ₜ  0.016632989067000392ₜ      0.6107231630089739ₜ  0.42073740024849027ₜ  0.12544096251286252ₜ

julia> B = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
   0.918668657448913ₜ  0.37130249677291616ₜ  0.015520172649508002ₜ  …    0.4217833483538528ₜ  0.09674614069589416ₜ   0.5220248427614098ₜ
  0.5427110584007996ₜ  0.07322138361871233ₜ   0.39817812413316944ₜ        0.613185938137799ₜ   0.7715787582868382ₜ  0.31678827369206486ₜ
 0.03385587708231008ₜ    0.419539772867648ₜ    0.6488635355579782ₜ       0.8168483311289406ₜ   0.7968272625334835ₜ   0.7543228522680858ₜ
  0.4214481610360705ₜ   0.8774178716087242ₜ    0.9152665792526814ₜ      0.42192605883285983ₜ  0.31593436071010317ₜ  0.03246567665943201ₜ
                    ⋮                                               ⋱                                               
  0.6005944456907697ₜ   0.5535862222464678ₜ    0.3587029529220066ₜ       0.7021111006644063ₜ  0.11623147797280275ₜ   0.4419447996528878ₜ
 0.46100269757903745ₜ   0.9508635480592903ₜ    0.6862088683444554ₜ       0.8850954067690757ₜ   0.7170910957898577ₜ   0.8571552217123121ₜ
 0.10608302296280459ₜ  0.42530792767361414ₜ    0.4809647511705907ₜ     0.052462251486652955ₜ   0.4963040842189812ₜ   0.8520380065634755ₜ

julia> C = A * B   # please measure the time taken
100×100 Matrix{Tropical{Float64}}:
 1.8121304872061192ₜ  1.9490382553413033ₜ  1.7739280657972318ₜ  …  1.7604605344080433ₜ  1.8407600667009578ₜ  1.7761143116771547ₜ
  1.911750667248952ₜ  1.9387393912158424ₜ  1.9000790633146418ₜ       1.85758009926937ₜ  1.8846788628832503ₜ    1.91081082401642ₜ
  1.803227348654226ₜ  1.9256978339759985ₜ  1.9669121819146451ₜ     1.7670268441589316ₜ   1.972369331395023ₜ      1.950556798981ₜ
 1.8628280622026812ₜ  1.8891281036629204ₜ   1.877842973367417ₜ     1.8102758011805267ₜ  1.9087597514137742ₜ  1.9220228433440867ₜ
                   ⋮                                            ⋱                                            
  1.833177249178683ₜ  1.7516073619261463ₜ  1.9516109517660836ₜ     1.9118305572090417ₜ  1.8012947894353855ₜ  1.7971610736497188ₜ
 1.7349603211612288ₜ  1.8824573735153756ₜ   1.956781546077444ₜ     1.8589429513203468ₜ  1.7719624434699615ₜ  1.8895085038782318ₜ
 1.8360707189447623ₜ  1.9182509887871912ₜ   1.879021495662182ₜ     1.8147029375368326ₜ  1.8527488911989527ₜ  1.8074609608070382ₜ

julia> @btime sum($(randn(1000)))
  60.614 ns (0 allocations: 0 bytes)
11.070827841408764

julia> @profile for i in 1:10; A * B; end

julia> Profile.print(format=:flat,mincount=10)
 Count  Overhead File                          Line Function
 =====  ======== ====                          ==== ========
   150         0 @Base/Base.jl                  130 eval
    24         0 REPL[20]                         1 +
   115         0 REPL[44]                         1 macro expansion
   115         0 REPL[44]                         1 top-level scope
    35         0 REPL[59]                         1 macro expansion
    35         0 REPL[59]                         1 top-level scope
    73         0 @Base/boot.jl                  578 Array
    73         0 @Base/boot.jl                  596 Array
    74        73 @Base/boot.jl                  516 GenericMemory
   150         0 @Base/boot.jl                  430 eval
   150         0 @Base/essentials.jl           1055 #invokelatest#2
    20        20 @Base/essentials.jl            796 ifelse
   150         0 @Base/essentials.jl           1052 invokelatest(::Any)
   150         0 @Base/logging/logging.jl       632 with_logger
   150         0 @Base/logging/logging.jl       522 with_logstate(f::VSCodeServer.var"#112#114"{Module, Expr, REPL.LineEditREP…
    19         0 @Base/math.jl                  839 max
    27        27 @Base/pointer.jl               180 unsafe_store!
    25         0 @Base/promotion.jl             633 muladd
    33         0 @Base/simdloop.jl               77 macro expansion
    35         0 @LinearAlgebra/src/matmul.jl   114 *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
    34         0 @LinearAlgebra/src/matmul.jl   895 _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float…
    34         0 @LinearAlgebra/src/matmul.jl   287 _mul!
    34         0 @LinearAlgebra/src/matmul.jl   868 generic_matmatmul!
    32         0 @LinearAlgebra/src/matmul.jl   896 macro expansion
    34         0 @LinearAlgebra/src/matmul.jl   253 mul!
    34         0 @LinearAlgebra/src/matmul.jl   285 mul!
   150         0 @Profile/src/Profile.jl         59 macro expansion
    29         0 @Random/src/Random.jl          269 rand!
    29         0 @Random/src/XoshiroSimd.jl     280 rand!
    29         0 @Random/src/XoshiroSimd.jl     141 xoshiro_bulk
    29         0 @Random/src/XoshiroSimd.jl     142 xoshiro_bulk
    27         0 @Random/src/XoshiroSimd.jl     238 xoshiro_bulk_simd(rng::TaskLocalRNG, dst::Ptr{UInt8}, len::Int64, ::Type{U…
   115         1 @Random/src/normal.jl          272 randn
   115         0 @Random/src/normal.jl          278 randn
    29         0 @Random/src/normal.jl          257 randn!(rng::TaskLocalRNG, A::Vector{Float64})
    10         0 @Random/src/normal.jl          260 randn!(rng::TaskLocalRNG, A::Vector{Float64})
   150         0 @VSCodeServer/src/eval.jl       34 (::VSCodeServer.var"#64#65")()
   150         0 @VSCodeServer/src/repl.jl      193 (::VSCodeServer.var"#111#113"{Module, Expr, REPL.LineEditREPL, REPL.LineEd…
   150         0 @VSCodeServer/src/repl.jl      192 #112
   150         0 @VSCodeServer/src/repl.jl      229 repleval(m::Module, code::Expr, ::String)
Total snapshots: 150. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```

TASK 2
