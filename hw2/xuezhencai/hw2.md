# Homework 2
## Task1
### Q1
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
```julia
julia> typeof(Tropical(1.0))
Tropical{Float64}

julia> supertype(Tropical{Float64})
AbstractSemiring
```

### Q3
```julia
julia> isconcretetype(Tropical)
false
```
So it is an **abstract** type.

### Q4
```julia
julia> isconcretetype(Tropical{Real})
true
```
So it is a **concrete** type.

### Q5
```julia
julia> using Random, BenchmarkTools

julia> A = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
  0.7136973310906211ₜ   0.8683237360386467ₜ  …   0.7924909423057922ₜ   0.6733416879555295ₜ
 0.27257961864547087ₜ   0.9332822156663859ₜ      0.6997718046735182ₜ   0.2628730084506157ₜ
   0.977828683847154ₜ   0.6145028144758721ₜ      0.6102307936241773ₜ  0.32228193238656366ₜ
 0.20452074675650533ₜ   0.4335004310649738ₜ       0.552862833839816ₜ   0.7171200428606128ₜ
  0.9673090202387906ₜ  0.01323919168223675ₜ      0.7678025985319726ₜ     0.65257113662738ₜ
                    ⋮                        ⋱                        
   0.604703873387723ₜ   0.5766093501775965ₜ     0.24117808152060238ₜ   0.7067689820835343ₜ
  0.7049817246449069ₜ   0.7323004498744555ₜ      0.7673877621951584ₜ   0.9388519888062525ₜ
 0.16446912152318305ₜ   0.9004907266684693ₜ     0.03477723973376934ₜ   0.6553901446310352ₜ
 0.33243650796535684ₜ  0.45551458755664864ₜ      0.5253961755366731ₜ   0.5023206945151214ₜ

julia> B = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
   0.3732101151191177ₜ  0.17141374052589986ₜ  …  0.026077473812002094ₜ   0.9109652130527892ₜ
   0.3830066895049298ₜ   0.4082827850827786ₜ      0.32506751968613357ₜ  0.42498191509764993ₜ
  0.34108635876272064ₜ  0.18042889171725063ₜ      0.04595849643722927ₜ  0.07461107343773987ₜ
  0.28311104836637135ₜ   0.2541143049911906ₜ       0.9165978558381562ₜ   0.6906156787766975ₜ
   0.2104301090550721ₜ   0.6372143479649311ₜ       0.4772259256596121ₜ   0.5895373112866241ₜ
                     ⋮                        ⋱                         
 0.032153649028814124ₜ  0.08226498859520415ₜ      0.46329154799301353ₜ  0.27419251291315483ₜ
    0.283973820935319ₜ   0.7568896453101815ₜ       0.3173598989331087ₜ   0.4214885018193142ₜ
   0.9531911261507551ₜ   0.8678621775107038ₜ       0.6678082699734856ₜ  0.40299403128917965ₜ
  0.26904077088332423ₜ   0.6683655330982126ₜ       0.2622258551410849ₜ  0.10477915621983769ₜ

julia> @btime C = $A * $B
  1.499 ms (3 allocations: 78.20 KiB)
100×100 Matrix{Tropical{Float64}}:
 1.8222918395672947ₜ   1.866581441321899ₜ  1.8863643839735853ₜ  …  1.9622073157734017ₜ  1.8617932849216992ₜ
 1.8875073635972244ₜ   1.877139463423514ₜ  1.8319341792914603ₜ     1.8594304701892486ₜ   1.800578542514875ₜ
  1.870277481790445ₜ  1.8512409438640978ₜ   1.966468063373335ₜ     1.8784945749270106ₜ  1.8887938968999434ₜ
 1.8217621021550565ₜ  1.8412320339703574ₜ  1.8505145083500887ₜ     1.8189726269298812ₜ  1.7707937903775965ₜ
 1.7772499981698602ₜ  1.8966295708674004ₜ   1.868665299733209ₜ     1.8272805868119035ₜ  1.9226403932093044ₜ
                   ⋮                                            ⋱                       
 1.9016093485625527ₜ  1.8267019313626234ₜ  1.8876004797354822ₜ     1.8293506060425688ₜ  1.8946260993152415ₜ
  1.916349142898886ₜ  1.9034738472333324ₜ    1.92559900407305ₜ      1.856615521109001ₜ   1.824120923093878ₜ
 1.8029694387184403ₜ  1.8967577191794631ₜ  1.9602116922910233ₜ     1.8172410853697443ₜ  1.9242864178204995ₜ
 1.8035704017894532ₜ  1.9656380744890416ₜ   1.956102916719897ₜ     1.9732130347854309ₜ  1.8796749141620106ₜ

julia> using Profile

julia> Profile.clear()

julia> @profile C = A * B
100×100 Matrix{Tropical{Float64}}:
 1.8222918395672947ₜ   1.866581441321899ₜ  1.8863643839735853ₜ  …  1.9622073157734017ₜ  1.8617932849216992ₜ
 1.8875073635972244ₜ   1.877139463423514ₜ  1.8319341792914603ₜ     1.8594304701892486ₜ   1.800578542514875ₜ
  1.870277481790445ₜ  1.8512409438640978ₜ   1.966468063373335ₜ     1.8784945749270106ₜ  1.8887938968999434ₜ
 1.8217621021550565ₜ  1.8412320339703574ₜ  1.8505145083500887ₜ     1.8189726269298812ₜ  1.7707937903775965ₜ
 1.7772499981698602ₜ  1.8966295708674004ₜ   1.868665299733209ₜ     1.8272805868119035ₜ  1.9226403932093044ₜ
                   ⋮                                            ⋱                       
 1.9016093485625527ₜ  1.8267019313626234ₜ  1.8876004797354822ₜ     1.8293506060425688ₜ  1.8946260993152415ₜ
  1.916349142898886ₜ  1.9034738472333324ₜ    1.92559900407305ₜ      1.856615521109001ₜ   1.824120923093878ₜ
 1.8029694387184403ₜ  1.8967577191794631ₜ  1.9602116922910233ₜ     1.8172410853697443ₜ  1.9242864178204995ₜ
 1.8035704017894532ₜ  1.9656380744890416ₜ   1.956102916719897ₜ     1.9732130347854309ₜ  1.8796749141620106ₜ

julia> Profile.print()
Overhead ╎ [+additional indent] Count File:Line; Function
=========================================================
  ╎43 @VSCodeServer/src/eval.jl:34; (::VSCodeServer.var"#64#65")()
  ╎ 43 @Base/essentials.jl:1052; invokelatest(::Any)
  ╎  43 @Base/essentials.jl:1055; #invokelatest#2
  ╎   43 @VSCodeServer/src/repl.jl:193; (::VSCodeServer.var"#111#113"{Module, Expr, REPL.LineEditREPL, REPL.L…
  ╎    43 @Base/logging/logging.jl:632; with_logger
  ╎     43 @Base/logging/logging.jl:522; with_logstate(f::VSCodeServer.var"#112#114"{Module, Expr, REPL.LineE…
  ╎    ╎ 43 @VSCodeServer/src/repl.jl:192; #112
  ╎    ╎  43 @VSCodeServer/src/repl.jl:229; repleval(m::Module, code::Expr, ::String)
  ╎    ╎   43 @Base/Base.jl:130; eval
37╎    ╎    43 @Base/boot.jl:430; eval
  ╎    ╎     5  @LinearAlgebra/src/matmul.jl:114; *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}…
  ╎    ╎    ╎ 5  @LinearAlgebra/src/matmul.jl:253; mul!
  ╎    ╎    ╎  5  @LinearAlgebra/src/matmul.jl:285; mul!
  ╎    ╎    ╎   5  @LinearAlgebra/src/matmul.jl:287; _mul!
  ╎    ╎    ╎    5  @LinearAlgebra/src/matmul.jl:868; generic_matmatmul!
  ╎    ╎    ╎     5  @LinearAlgebra/src/matmul.jl:895; _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::M…
  ╎    ╎    ╎    ╎ 5  @Base/simdloop.jl:77; macro expansion
  ╎    ╎    ╎    ╎  5  @LinearAlgebra/src/matmul.jl:896; macro expansion
 1╎    ╎    ╎    ╎   1  @Base/array.jl:994; setindex!
  ╎    ╎    ╎    ╎   4  @Base/promotion.jl:633; muladd
  ╎    ╎    ╎    ╎    4  …bers/src/tropical_maxplus.jl:67; +
  ╎    ╎    ╎    ╎     1  @Base/math.jl:838; max
 1╎    ╎    ╎    ╎    ╎ 1  @Base/float.jl:492; -
  ╎    ╎    ╎    ╎     3  @Base/math.jl:839; max
 3╎    ╎    ╎    ╎    ╎ 3  @Base/essentials.jl:796; ifelse
Total snapshots: 49. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```
## Task2
```julia
function ⊕(s::Set{Int}, t::Set{Int})
    return union(s, t)
end

function ⊙(s::Set{Int}, t::Set{Int})
    if isempty(t)
        return Set{Int}()
    else
        return Set([a * b for a in s for b in t])
    end
end

setzero = Set{Int}()
setone = Set([1])

using Test

@testset "Semiring Algebra Tests" begin
    @test ⊕(Set([2]), Set([5,4])) == Set([2,4,5])
    @test ⊕(Set([5,4]), Set([2])) == Set([2,4,5])
    @test ⊕(Set([2]), setzero) == Set([2])
    
    @test ⊙(Set([2]), Set([5,4])) == Set([10,8])
    @test ⊙(Set([5,4]), Set([2])) == Set([10,8])
    @test ⊙(Set([2]), setzero) == Set{Int}()
    @test ⊙(Set([2]), setone) == Set([2])
end

println("All tests passed!")
```
```julia
All tests passed!
```