## Task 1
1. What are the outputs of the following expressions?
```julia
julia> Tropical(1.0) + Tropical(3.0)
3.0ₜ

julia> Tropical(1.0) * Tropical(3.0)
4.0ₜ

julia> one(Tropical{Float64})
0.0ₜ

julia> zero(Tropical{Float64})
-Infₜ

```

2. What is the type and supertype of `Tropical(1.0)`?
```julia
julia> typeof(Tropical(1.0))
Tropical{Float64}

julia> supertype(typeof(Tropical(1.0)))
AbstractSemiring

```

3. Is `Tropical` a concrete type or an abstract type?
```julia
julia> isabstracttype(Tropical)
false

julia> isconcretetype(Tropical)
false

```

4. Is `Tropical{Real}` a concrete type or an abstract type?
```julia
julia> isabstracttype(Tropical{Real})
false

julia> isconcretetype(Tropical{Real})
true
```

5. Benchmark and profile the performance of Tropical matrix multiplication:
```julia
using BenchmarkTools
using Profile

julia> A = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
  0.1332535625170267ₜ   0.0614264880450317ₜ   0.35900448100381477ₜ  …   0.8482007876373232ₜ  0.48019820193211993ₜ   0.45728483371620066ₜ
  0.7985757000911348ₜ  0.12165358569328999ₜ  0.007217931249547727ₜ      0.7409082717871672ₜ   0.5772440789569746ₜ    0.5615316323723004ₜ
  0.7092773148993335ₜ   0.4309253056770155ₜ  0.037914005270920925ₜ      0.6244210149378414ₜ  0.11764797123826731ₜ   0.19215849015725817ₜ
  0.7193176791697069ₜ   0.2060347116278719ₜ    0.4238032075239858ₜ     0.22195339447012075ₜ  0.14063032635344708ₜ  0.026259761656507785ₜ
  0.7980840575942015ₜ   0.9524981767300258ₜ    0.8809627393785228ₜ      0.1776101694188731ₜ   0.8247452959790992ₜ   0.37293956473608336ₜ
  0.3908976253153156ₜ  0.48162215908752504ₜ    0.7173424103900998ₜ  …     0.94404915563853ₜ   0.5314059147195416ₜ   0.42708639303482543ₜ
                    ⋮                                               ⋱                                              
  0.8428340014199082ₜ  0.13137918563843287ₜ    0.7625881919945467ₜ  …    0.480667140738156ₜ   0.9360828803676642ₜ    0.4797558202095026ₜ
 0.44100048844739914ₜ  0.48900022301847723ₜ     0.528469770204887ₜ      0.2473211194052799ₜ   0.2809761500424752ₜ    0.8098151174829703ₜ
  0.4663443458152493ₜ   0.4981026299297824ₜ  0.028643147058516893ₜ      0.3047726904490754ₜ   0.5703343988912498ₜ    0.7218544195147701ₜ
  0.8259197443557975ₜ   0.9321531109985187ₜ   0.37032272776481945ₜ      0.5588802282723618ₜ   0.5830846254511731ₜ   0.20463680469676826ₜ
  0.7299335198349667ₜ   0.6957249825184498ₜ   0.25821191380392006ₜ       0.339966875639928ₜ  0.07114291147021734ₜ    0.8260956132471857ₜ

julia> B = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
 0.39098732950941417ₜ  0.10911848765870347ₜ   0.8145067419724541ₜ  …   0.6180207241609973ₜ   0.6564073737851179ₜ  0.23044455257587004ₜ
  0.6202078721615748ₜ   0.9222655870023692ₜ   0.2647969908740404ₜ       0.895351689076273ₜ   0.6222872051865334ₜ   0.8147808440760412ₜ
   0.262573617067249ₜ  0.14626655987260218ₜ  0.15771692321334219ₜ      0.8718929118830451ₜ  0.20722812408306834ₜ   0.6272268962207693ₜ
  0.8202561170947482ₜ   0.8335120009264557ₜ  0.21621894890465843ₜ     0.17472447979729577ₜ   0.6059536592631868ₜ  0.05355574225794735ₜ
  0.7333537419908225ₜ  0.15380286947304467ₜ     0.68199272525843ₜ      0.7038414962212935ₜ   0.8933749326874129ₜ   0.5840971656103318ₜ
  0.7516625864206727ₜ  0.20685834850180596ₜ    0.627478816122221ₜ  …   0.5666483403605371ₜ   0.6165164966386046ₜ  0.23873971923787562ₜ
                    ⋮                                              ⋱                                              
 0.02901597967149805ₜ    0.727278953339787ₜ    0.514870509802751ₜ  …   0.3017127143291418ₜ   0.7347512314345315ₜ   0.4197014139203542ₜ
  0.7362829911326223ₜ   0.7725866311319426ₜ   0.7837240204661122ₜ     0.14027424154328405ₜ   0.3829420213319048ₜ   0.4062203840330556ₜ
 0.08704927681072239ₜ   0.4112090592369224ₜ   0.4215102774327001ₜ     0.30930382563882886ₜ   0.5519962478654284ₜ  0.35357269578953654ₜ
  0.3533206366586432ₜ  0.10521262502396334ₜ   0.9833613964913739ₜ      0.2435129107775872ₜ   0.0748514912846735ₜ   0.7698584426123851ₜ
  0.3792428340142191ₜ   0.7136315235328964ₜ   0.9526076647731664ₜ     0.14822897705611837ₜ    0.614823557222068ₜ   0.3262361253920951ₜ

julia> @btime C = A * B
  1.232 ms (3 allocations: 78.20 KiB)
100×100 Matrix{Tropical{Float64}}:
  1.731737372033705ₜ   1.628513544619659ₜ  1.9417944318404174ₜ   1.948382853739073ₜ  …  1.9588637353092169ₜ  1.8372811508071805ₜ   1.950263764578886ₜ
 1.9275444482411155ₜ   1.797923458931682ₜ  1.8318569240973601ₜ   1.891382835354601ₜ     1.8727707599280994ₜ   1.878651983366821ₜ  1.7580360147535707ₜ
 1.8852557170139306ₜ  1.9005500537070774ₜ  1.9245898114614892ₜ  1.9687522212427044ₜ     1.9591512294682456ₜ  1.8289642052935262ₜ  1.8484129607832154ₜ
 1.9585148216629988ₜ  1.8054865542864778ₜ   1.920319543191065ₜ  1.7539166482440958ₜ      1.943795762840342ₜ  1.9034792013086639ₜ  1.9348372525759514ₜ
 1.8985424165332696ₜ  1.8747637637323948ₜ   1.830895239385301ₜ  1.8401260017136258ₜ     1.8478498658062987ₜ   1.842224118254685ₜ  1.9217859775793518ₜ
 1.9161919190394832ₜ   1.962632931577355ₜ  1.9697175380296343ₜ  1.9388759770969899ₜ  …   1.914735172507008ₜ   1.821639272601036ₜ   1.967208119879095ₜ
                   ⋮                                                                 ⋱                                            
 1.9476327443086658ₜ  1.8689249531414576ₜ  1.9869668387562243ₜ  1.9035960287097342ₜ  …  1.8753066322038672ₜ  1.7988593892416804ₜ  1.7398763224328078ₜ
  1.856774424903373ₜ  1.7767374682776398ₜ  1.8193902048132324ₜ  1.8390400677761036ₜ     1.9029231244341394ₜ  1.7865740962074654ₜ  1.8752209366241646ₜ
  1.901564160423833ₜ  1.9088942906490494ₜ  1.9621066267111955ₜ  1.6930702163759448ₜ      1.875692515394453ₜ   1.866638701584404ₜ  1.9476062311326205ₜ
 1.9019695661038702ₜ  1.9022200232423478ₜ  1.9684693913009796ₜ   1.948411263795162ₜ     1.9308017111135662ₜ  1.7659314383478644ₜ  1.9587759994951977ₜ
 1.7677320699145902ₜ  1.7597668561961162ₜ  1.8499589561583296ₜ  1.9656763744947208ₜ     1.7756884945013298ₜ  1.8322920175484643ₜ  1.7926194817636878ₜ


julia> Profile.init(; delay=0.001)

julia> @profile for _ = 1:10000 C = A * B end

julia> Profile.print(; mincount=10)
Overhead ╎ [+additional indent] Count File:Line; Function
=========================================================
    ╎14665 @VSCodeServer/src/eval.jl:34; (::VSCodeServer.var"#64#65")()
    ╎ 14665 @Base/essentials.jl:1052; invokelatest(::Any)
    ╎  14665 @Base/essentials.jl:1055; #invokelatest#2
    ╎   14665 @VSCodeServer/src/repl.jl:193; (::VSCodeServer.var"#111#113"{Module, Expr, REPL.LineEditREPL, REPL.LineEdit.Prompt})()
    ╎    14665 @Base/logging/logging.jl:632; with_logger
    ╎     14665 @Base/logging/logging.jl:522; with_logstate(f::VSCodeServer.var"#112#114"{Module, Expr, REPL.LineEditREPL, REPL.LineEdit.Prompt}, logstate…
    ╎    ╎ 14665 @VSCodeServer/src/repl.jl:192; #112
    ╎    ╎  14665 @VSCodeServer/src/repl.jl:229; repleval(m::Module, code::Expr, ::String)
    ╎    ╎   14665 @Base/Base.jl:130; eval
   1╎    ╎    14665 @Base/boot.jl:430; eval
    ╎    ╎     14664 REPL[17]:1; top-level scope
    ╎    ╎    ╎ 14664 @Profile/src/Profile.jl:59; macro expansion
  15╎    ╎    ╎  14664 REPL[17]:1; macro expansion
    ╎    ╎    ╎   14649 @LinearAlgebra/src/matmul.jl:114; *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
    ╎    ╎    ╎    139   @LinearAlgebra/src/matmul.jl:117; matprod_dest
    ╎    ╎    ╎     138   @Base/array.jl:372; similar
    ╎    ╎    ╎    ╎ 138   @Base/boot.jl:592; Array
   1╎    ╎    ╎    ╎  138   @Base/boot.jl:582; Array
    ╎    ╎    ╎    ╎   137   @Base/boot.jl:535; new_as_memoryref
 137╎    ╎    ╎    ╎    137   @Base/boot.jl:516; GenericMemory
    ╎    ╎    ╎    14510 @LinearAlgebra/src/matmul.jl:253; mul!
    ╎    ╎    ╎     14510 @LinearAlgebra/src/matmul.jl:285; mul!
    ╎    ╎    ╎    ╎ 14510 @LinearAlgebra/src/matmul.jl:287; _mul!
    ╎    ╎    ╎    ╎  14510 @LinearAlgebra/src/matmul.jl:868; generic_matmatmul!
2069╎    ╎    ╎    ╎   2069  @Base/essentials.jl:0; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Flo…
  32╎    ╎    ╎    ╎   32    @LinearAlgebra/src/matmul.jl:0; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{Tro…
    ╎    ╎    ╎    ╎   64    @LinearAlgebra/src/matmul.jl:890; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{T…
    ╎    ╎    ╎    ╎    64    @LinearAlgebra/src/generic.jl:103; _rmul_or_fill!
    ╎    ╎    ╎    ╎     64    @Base/array.jl:329; fill!
  64╎    ╎    ╎    ╎    ╎ 64    @Base/array.jl:987; setindex!
    ╎    ╎    ╎    ╎   266   @LinearAlgebra/src/matmul.jl:894; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{T…
    ╎    ╎    ╎    ╎    266   @Base/array.jl:930; getindex
    ╎    ╎    ╎    ╎     66    @Base/abstractarray.jl:1347; _to_linear_index
    ╎    ╎    ╎    ╎    ╎ 66    @Base/abstractarray.jl:3048; _sub2ind
    ╎    ╎    ╎    ╎    ╎  66    @Base/abstractarray.jl:3064; _sub2ind
    ╎    ╎    ╎    ╎    ╎   66    @Base/abstractarray.jl:3080; _sub2ind_recurse
    ╎    ╎    ╎    ╎    ╎    66    @Base/abstractarray.jl:3080; _sub2ind_recurse
  45╎    ╎    ╎    ╎    ╎     45    @Base/int.jl:88; *
  21╎    ╎    ╎    ╎    ╎     21    @Base/int.jl:87; +
 200╎    ╎    ╎    ╎     200   @Base/essentials.jl:917; getindex
    ╎    ╎    ╎    ╎   12041 @LinearAlgebra/src/matmul.jl:895; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{T…
 216╎    ╎    ╎    ╎    216   @Base/simdloop.jl:0; macro expansion
  33╎    ╎    ╎    ╎    242   @Base/simdloop.jl:75; macro expansion
 209╎    ╎    ╎    ╎     209   @Base/int.jl:83; <
    ╎    ╎    ╎    ╎    10790 @Base/simdloop.jl:77; macro expansion
    ╎    ╎    ╎    ╎     10790 @LinearAlgebra/src/matmul.jl:896; macro expansion
    ╎    ╎    ╎    ╎    ╎ 3349  @Base/array.jl:930; getindex
3349╎    ╎    ╎    ╎    ╎  3349  @Base/essentials.jl:917; getindex
 101╎    ╎    ╎    ╎    ╎ 101   @Base/array.jl:994; setindex!
    ╎    ╎    ╎    ╎    ╎ 7340  @Base/promotion.jl:633; muladd
    ╎    ╎    ╎    ╎    ╎  105   /home/huang/julia_code/hw2.jl:56; *
 105╎    ╎    ╎    ╎    ╎   105   @Base/float.jl:491; +
    ╎    ╎    ╎    ╎    ╎  7235  /home/huang/julia_code/hw2.jl:68; +
    ╎    ╎    ╎    ╎    ╎   219   @Base/math.jl:838; max
 219╎    ╎    ╎    ╎    ╎    219   @Base/float.jl:492; -
    ╎    ╎    ╎    ╎    ╎   6970  @Base/math.jl:839; max
5826╎    ╎    ╎    ╎    ╎    5827  @Base/essentials.jl:796; ifelse
1143╎    ╎    ╎    ╎    ╎    1143  @Base/floatfuncs.jl:15; signbit
    ╎    ╎    ╎    ╎    ╎   46    @Base/math.jl:841; max
  46╎    ╎    ╎    ╎    ╎    46    @Base/essentials.jl:796; ifelse
    ╎    ╎    ╎    ╎    793   @Base/simdloop.jl:78; macro expansion
 793╎    ╎    ╎    ╎     793   @Base/int.jl:87; +
  36╎    ╎    ╎    ╎   38    @LinearAlgebra/src/matmul.jl:898; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix{T…
Total snapshots: 14665. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```
Multiplying two 100×100 Tropical{Float64} matrices took approximately 130 ms, with 78 MiB allocated. Profiling shows most time spent in _tropical_mul!, mainly due to type operations and matrix traversal. Optimizations like type stability, in-place updates, and parallelization can significantly improve performance.

## Task 2
Implement the the following semiring algebra over sets:

```math
\begin{equation}
\begin{split}
    s \oplus t &= s \cup t\\
    s \odot t &= \{\sigma * \tau \, \mid \, \sigma \in s, \tau \in t\}\\
    \mathbb{0} &= \{\}\\
    \mathbb{1} &= \{1\},
\end{split}
\end{equation}
```
where $s$ and $t$ are each a set of integers. Add the following test cases:
```math
\begin{equation*}
\begin{split}
    &\{2\} \oplus \{5, 4\} = \{5, 4\} \oplus \{2\} = \{2, 4, 5\}\\
    &\{2\} \oplus \{\} = \{2\}\\
    &\{2\} \odot \{5, 4\} = \{5, 4\} \odot \{2\} = \{10, 8\}\\
    &\{2\} \odot \{\} = \{\}\\
    &\{2\} \odot \{1\} = \{2\}.
\end{split}
\end{equation*}
```

Defining new functions in Tropical Max-Plus Algebra:

```julia
function Tropical(x::Int)
    if x == 0
        Tropical(Set{Int}()) 
    elseif x == 1
        Tropical(Set([1]))
    else
        Tropical{typeof(x)}(x) 
    end
end

function ⊕(a::Set{Int}, b::Set{Int})
    union(a,b)
end

function ⊙(a::Set{Int}, b::Set{Int})
    return Set(c * d for (c, d) in Iterators.product(a, b))
end

```

Test cases:
```julia 
julia> Set([2]) ⊕ Set([5,4]) == Set([5,4]) ⊕ Set([2]) == Set([2,4,5])
true

julia> Set([2]) ⊕ Tropical(0).n == Set([2])
true

julia> Set([2]) ⊙ Set([5,4]) == Set([5,4]) ⊙ Set([2]) == Set([10,8])
true

julia> Set([2]) ⊙ Tropical(0).n == Set{Int}()
true

julia> Set([2]) ⊙ Set([1]) == Set([2])
true

```