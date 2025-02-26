# HW2 Task
HU Zhiyang 20669668

## Task1

### Q1
What are the outputs of the following expressions?

```julia
julia> Tropical(1.0) + Tropical(3.0)
julia> Tropical(1.0) * Tropical(3.0)
julia> one(Tropical{Float64})
julia> zero(Tropical{Float64})
```

### A1
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

### Q2
What is the type and supertype of `Tropical(1.0)`?

### A2
```julia
julia> typeof(Tropical(1.0))
Tropical{Float64}

julia> supertype(typeof(Tropical(1.0)))
AbstractSemiring
```

### Q3
Is `Tropical` a concrete type or an abstract type?

### A3
```julia
julia> isconcretetype(Tropical)
false
```

It is an abstract type.

### Q4
Is `Tropical{Real}` a concrete type or an abstract type?

### A4
```julia
julia> isconcretetype(Tropical{Real})
true
```

It is a concrete type.

### Q5
Benchmark and profile the performance of Tropical matrix multiplication:

```julia
A = rand(Tropical{Float64}, 100, 100)
B = rand(Tropical{Float64}, 100, 100)
C = A * B   # please measure the time taken
```

write a brief report on the performance of the tropical matrix multiplication.

### A5
```julia
julia> using BenchmarkTools

julia> using Profile

julia> A = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
  0.8625062431510291ₜ   0.4801504412441385ₜ  0.5667457071983967ₜ  …   0.4203839475562068ₜ  0.7903478423422639ₜ
  0.1576387084748514ₜ  0.18834586067768888ₜ  0.2155653773992391ₜ      0.5787115185250201ₜ  0.3818343867900712ₜ
  0.9684199951718527ₜ   0.8900670007893694ₜ  0.7215559288076502ₜ     0.19189692519816126ₜ  0.5232380978907296ₜ
  0.5574333024468696ₜ   0.9756397075700579ₜ  0.7329429032817785ₜ      0.2039830511742725ₜ  0.1660202175403711ₜ
                    ⋮                                             ⋱
  0.9527669160098231ₜ   0.5715006569648791ₜ  0.9858626562203915ₜ      0.2568459372690238ₜ  0.4920317742639948ₜ
 0.16504133261616627ₜ   0.9751579365528504ₜ  0.1359458720321719ₜ      0.6654043725736785ₜ   0.554303964859785ₜ
  0.9710878619120022ₜ   0.7133812549077247ₜ  0.9267369680764359ₜ     0.23418414388365627ₜ  0.1579036524233287ₜ

julia> B = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
  0.8077410693579736ₜ  0.018349027071868806ₜ  0.26441059415208745ₜ  …   0.4129384425729036ₜ   0.8317262496748392ₜ
 0.25871433057670357ₜ   0.01124843665057007ₜ   0.1013215533619578ₜ      0.2152073852665417ₜ   0.9847353826261045ₜ
  0.9353696767226906ₜ    0.5987994595420092ₜ   0.9557287816361424ₜ      0.7833012886069904ₜ   0.9591070539508684ₜ
  0.2313219280476827ₜ   0.12344692330318296ₜ   0.9724640863001894ₜ      0.3916303349024104ₜ   0.7094163721220135ₜ
                    ⋮                                               ⋱
  0.1342823921733477ₜ    0.5819076792467526ₜ    0.719636217509169ₜ     0.23378879053148205ₜ   0.6719977118152263ₜ
  0.3796064687215538ₜ    0.5936123409972611ₜ   0.9859933225591305ₜ      0.7672606775459864ₜ   0.8473457401806485ₜ
  0.7574202191984091ₜ    0.9611922621890232ₜ   0.6938396359485443ₜ     0.25395163489849737ₜ  0.25805488403163435ₜ

julia> @btime C = A * B
  960.722 μs (3 allocations: 78.20 KiB)
100×100 Matrix{Tropical{Float64}}:
  1.870447848336619ₜ  1.9348181573924852ₜ  1.8944535362691353ₜ  …   1.904618578507187ₜ  1.8895689563902247ₜ   1.948139063146087ₜ
 1.9522774113334156ₜ  1.9182849476679902ₜ  1.9343996464417843ₜ     1.9875759975626148ₜ  1.8258738341105198ₜ  1.7941294691369882ₜ
 1.9636126090751587ₜ  1.8867972953837868ₜ  1.9413022156741995ₜ     1.8239545951234248ₜ  1.8398853360465526ₜ  1.9680240877072377ₜ
 1.9000989829650383ₜ  1.9073468977167622ₜ  1.7243748945479638ₜ     1.8795748701163124ₜ  1.8583231420544273ₜ  1.9603750901961625ₜ
                   ⋮                                            ⋱
 1.9335905017999724ₜ  1.8567751881086003ₜ   1.941591437856534ₜ      1.925179283242957ₜ  1.8736759871528401ₜ    1.94496971017126ₜ
  1.712855613633324ₜ  1.9187237805612511ₜ   1.864910554477524ₜ      1.985312266217059ₜ   1.891810753121014ₜ   1.959893319178955ₜ
 1.8621066447991264ₜ  1.8431750564030467ₜ  1.8824657497125783ₜ     1.9468216548634731ₜ   1.810822087247543ₜ   1.902578474435663ₜ

julia> Profile.init(; delay=0.001)

julia> @profile for _ = 1:10000
           C = A * B
       end

julia> Profile.print(; mincount=10)
Overhead ╎ [+additional indent] Count File:Line; Function
=========================================================
    ╎9147 @VSCodeServer/src/eval.jl:34; (::VSCodeServer.var"#64#65")()
    ╎ 9147 @Base/essentials.jl:1052; invokelatest(::Any)
    ╎  9147 @Base/essentials.jl:1055; #invokelatest#2
    ╎   9147 @VSCodeServer/src/repl.jl:193; (::VSCodeServer.var"#111#113"{Module, Expr, REPL.LineEditREPL, REPL.LineEdit.Prompt})()
    ╎    9147 @Base/logging/logging.jl:632; with_logger
    ╎     9147 @Base/logging/logging.jl:522; with_logstate(f::VSCodeServer.var"#112#114"{Module, Expr, REPL.LineEditREPL, REPL.Lin…
    ╎    ╎ 9147 @VSCodeServer/src/repl.jl:192; #112
    ╎    ╎  9147 @VSCodeServer/src/repl.jl:229; repleval(m::Module, code::Expr, ::String)
    ╎    ╎   9147 @Base/Base.jl:130; eval
   1╎    ╎    9147 @Base/boot.jl:430; eval
    ╎    ╎     9146 REPL[8]:1; top-level scope
    ╎    ╎    ╎ 9146 @Profile/src/Profile.jl:59; macro expansion
   5╎    ╎    ╎  9146 REPL[8]:2; macro expansion
    ╎    ╎    ╎   9140 @LinearAlgebra/src/matmul.jl:114; *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
    ╎    ╎    ╎    96   @LinearAlgebra/src/matmul.jl:117; matprod_dest
    ╎    ╎    ╎     95   @Base/array.jl:372; similar
    ╎    ╎    ╎    ╎ 95   @Base/boot.jl:592; Array
    ╎    ╎    ╎    ╎  95   @Base/boot.jl:582; Array
    ╎    ╎    ╎    ╎   95   @Base/boot.jl:535; new_as_memoryref
  95╎    ╎    ╎    ╎    95   @Base/boot.jl:516; GenericMemory
    ╎    ╎    ╎    9044 @LinearAlgebra/src/matmul.jl:253; mul!
    ╎    ╎    ╎     9044 @LinearAlgebra/src/matmul.jl:285; mul!
    ╎    ╎    ╎    ╎ 9044 @LinearAlgebra/src/matmul.jl:287; _mul!
    ╎    ╎    ╎    ╎  9044 @LinearAlgebra/src/matmul.jl:868; generic_matmatmul!
  37╎    ╎    ╎    ╎   37   @Base/essentials.jl:0; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}},…
    ╎    ╎    ╎    ╎   38   @LinearAlgebra/src/matmul.jl:890; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical…
    ╎    ╎    ╎    ╎    38   @LinearAlgebra/src/generic.jl:103; _rmul_or_fill!
    ╎    ╎    ╎    ╎     38   @Base/array.jl:329; fill!
  38╎    ╎    ╎    ╎    ╎ 38   @Base/array.jl:987; setindex!
    ╎    ╎    ╎    ╎   144  @LinearAlgebra/src/matmul.jl:894; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical…
    ╎    ╎    ╎    ╎    144  @Base/array.jl:930; getindex
    ╎    ╎    ╎    ╎     57   @Base/abstractarray.jl:1347; _to_linear_index
    ╎    ╎    ╎    ╎    ╎ 57   @Base/abstractarray.jl:3048; _sub2ind
    ╎    ╎    ╎    ╎    ╎  57   @Base/abstractarray.jl:3064; _sub2ind
    ╎    ╎    ╎    ╎    ╎   57   @Base/abstractarray.jl:3080; _sub2ind_recurse
    ╎    ╎    ╎    ╎    ╎    57   @Base/abstractarray.jl:3080; _sub2ind_recurse
  28╎    ╎    ╎    ╎    ╎     28   @Base/int.jl:88; *
  29╎    ╎    ╎    ╎    ╎     29   @Base/int.jl:87; +
  87╎    ╎    ╎    ╎     87   @Base/essentials.jl:917; getindex
    ╎    ╎    ╎    ╎   8807 @LinearAlgebra/src/matmul.jl:895; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical…
 239╎    ╎    ╎    ╎    849  @Base/simdloop.jl:75; macro expansion
 610╎    ╎    ╎    ╎     610  @Base/int.jl:83; <
    ╎    ╎    ╎    ╎    7878 @Base/simdloop.jl:77; macro expansion
    ╎    ╎    ╎    ╎     7878 @LinearAlgebra/src/matmul.jl:896; macro expansion
    ╎    ╎    ╎    ╎    ╎ 1708 @Base/array.jl:930; getindex
1708╎    ╎    ╎    ╎    ╎  1708 @Base/essentials.jl:917; getindex
2022╎    ╎    ╎    ╎    ╎ 2022 @Base/array.jl:994; setindex!
    ╎    ╎    ╎    ╎    ╎ 4148 @Base/promotion.jl:633; muladd
    ╎    ╎    ╎    ╎    ╎  280  …/hw2/huzhiyang/TropicalMaxPlus.jl:36; *
 280╎    ╎    ╎    ╎    ╎   280  @Base/float.jl:491; +
    ╎    ╎    ╎    ╎    ╎  3868 …/hw2/huzhiyang/TropicalMaxPlus.jl:48; +
    ╎    ╎    ╎    ╎    ╎   179  @Base/math.jl:838; max
 179╎    ╎    ╎    ╎    ╎    179  @Base/float.jl:492; -
    ╎    ╎    ╎    ╎    ╎   2455 @Base/math.jl:839; max
2268╎    ╎    ╎    ╎    ╎    2269 @Base/essentials.jl:796; ifelse
 186╎    ╎    ╎    ╎    ╎    186  @Base/floatfuncs.jl:15; signbit
    ╎    ╎    ╎    ╎    ╎   1234 @Base/math.jl:841; max
1234╎    ╎    ╎    ╎    ╎    1234 @Base/essentials.jl:796; ifelse
    ╎    ╎    ╎    ╎    80   @Base/simdloop.jl:78; macro expansion
  80╎    ╎    ╎    ╎     80   @Base/int.jl:87; +
  16╎    ╎    ╎    ╎   17   @LinearAlgebra/src/matmul.jl:898; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical…
Total snapshots: 9148. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```

Julia run the Tropical matrix multiplication very fast. In this case, it used 960.722 μs computing time. To get more samples we run the matrix multiplication 10000 times. By using Profile, we find that the most time-consuming part is `@Base/essentials.jl:796; ifelse`, `@Base/essentials.jl:917; getindex`, `@Base/array.jl:994; setindex!`, `@Base/int.jl:83; <`.

## Task2
This is the newset code and the test cases.

```julia
# set definition
function ⊕(s::Set{Int}, t::Set{Int})
    return union(s, t)
end

function ⊙(s::Set{Int}, t::Set{Int})
    return Set([a * b for a in s for b in t])
end

setzero = Set{Int}()
setone = Set([1])

# test cases
@assert ⊕(Set([2]), Set([5,4])) == Set([2,4,5])
@assert ⊕(Set([5,4]), Set([2])) == Set([2,4,5])
@assert ⊕(Set([2]), setzero) == Set([2])
@assert ⊙(Set([2]), Set([5,4])) == Set([10,8])
@assert ⊙(Set([5,4]), Set([2])) == Set([10,8])
@assert ⊙(Set([2]), setzero) == Set{Int}()
@assert ⊙(Set([2]), setone) == Set([2])

println("pass test")
```