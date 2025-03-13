```
1. julia> Tropical(1.0) + Tropical(3.0)
3.0ₜ

julia> Tropical(1.0) * Tropical(3.0)
4.0ₜ

julia> one(Tropical{Float64})
0.0ₜ

julia> zero(Tropical{Float64})
-Infₜ
```
```
2. type: Tropical{Float64}; 

   supertype: AbstractSemiring
```
```
3. neither concrete type nor abstract type
```
```
4. concrete type
```
```
5. julia> using BenchmarkTools

julia> using Profile

julia> A = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
  0.9842394303816675ₜ  0.12442988212543438ₜ  0.46031974139936516ₜ  …   0.5039707550134431ₜ    0.441429337996772ₜ    0.2166101511785905ₜ
 0.34231631156430087ₜ  0.12522140096217182ₜ  0.09685422922365172ₜ      0.8760404314948553ₜ   0.5866688508711596ₜ    0.6506784171791411ₜ
 0.05184891176850526ₜ   0.2681480070750284ₜ   0.4307163507230479ₜ     0.44724688191912587ₜ   0.7399566129397537ₜ  0.013295360886296681ₜ
  0.9330254181097662ₜ  0.46351213995131424ₜ   0.9314343085025039ₜ     0.30466758447888376ₜ  0.22192197273395586ₜ    0.0411699411613865ₜ
                    ⋮                                              ⋱                                              
  0.7970216981384819ₜ   0.6116465346282385ₜ   0.9505310041107723ₜ     0.13073552441783376ₜ   0.9302082981443703ₜ    0.6398475681359284ₜ
  0.9174905458726449ₜ   0.5577350623937021ₜ  0.30943662404811056ₜ      0.6496554825684362ₜ  0.13196480385529974ₜ   0.26968411639123757ₜ
  0.7177239648514925ₜ   0.9651224123117218ₜ    0.806647264372936ₜ      0.6691760426947306ₜ  0.43780487732937534ₜ     0.657909916172972ₜ
 0.36786365856051284ₜ   0.6961098963632779ₜ  0.14535207884788204ₜ     0.42917135889604563ₜ   0.7140073311630228ₜ   0.15409837300963902ₜ

julia> B = rand(Tropical{Float64}, 100, 100)
100×100 Matrix{Tropical{Float64}}:
  0.3228498950221568ₜ   0.5985347341397991ₜ  0.35113625715484453ₜ   0.01064114654906656ₜ  …   0.5067716150544762ₜ  0.18237979032600682ₜ   0.7676313299590175ₜ
 0.03311625539469931ₜ   0.9646540146772504ₜ   0.3162753720316728ₜ     0.833656486248295ₜ      0.6492197111216479ₜ   0.4683159713187264ₜ   0.7791908345708461ₜ
  0.4044942671543199ₜ   0.4139969160379965ₜ  0.08135919964123295ₜ    0.2169589943018977ₜ     0.15615173591181064ₜ  0.10902830710014255ₜ   0.5391044634176284ₜ
  0.2742177915336257ₜ   0.7226245865103296ₜ   0.8949427236196736ₜ    0.7467607424314499ₜ      0.5525323422716966ₜ   0.6332598622031392ₜ  0.03085957774296144ₜ
                    ⋮                                                                     ⋱                                              
  0.4080549125811421ₜ   0.4799688562065755ₜ   0.7233474679942055ₜ    0.1927516991149799ₜ      0.8610030366592756ₜ   0.7985546451687218ₜ   0.9365088721794391ₜ
  0.7470840312935515ₜ   0.9964303877335987ₜ   0.7346722008072106ₜ  0.004044123563131108ₜ     0.04825182492420621ₜ  0.14112617144318473ₜ   0.3333631608145997ₜ
   0.785924290915524ₜ   0.5219865038707631ₜ   0.4496487179844968ₜ  0.021805889991941774ₜ     0.41406599322745996ₜ   0.7773310792185709ₜ  0.43894905220986513ₜ
  0.6629533210282428ₜ  0.37168145534976493ₜ   0.2254377015629796ₜ   0.45809775864599867ₜ     0.26683152013469147ₜ  0.32139816458135495ₜ  0.32652720083810927ₜ

julia> @btime C = A * B # 2.066 ms

  2.182 ms (3 allocations: 78.20 KiB)
100×100 Matrix{Tropical{Float64}}:
 1.9221103002835997ₜ  1.8919463502529967ₜ    1.87577250032724ₜ   1.915073111237024ₜ  …  1.9053656929924485ₜ  1.9256599526730973ₜ  1.9738756710371832ₜ
 1.9044782662594741ₜ   1.872470819228454ₜ  1.9259084438104277ₜ  1.8812888862754074ₜ     1.8109835052725356ₜ  1.9082994547149699ₜ   1.890375327242554ₜ
 1.9850094417353248ₜ  1.9548454917047215ₜ   1.874825314245934ₜ  1.7892412799060537ₜ     1.8661327755155024ₜ  1.9623295371069314ₜ   1.916703953952311ₜ
 1.8813732847908633ₜ   1.984635707833109ₜ  1.9499326701940911ₜ     1.7919007033964ₜ     1.8720311234194573ₜ  1.8129032626308397ₜ  1.8945153532818064ₜ
                   ⋮                                                                 ⋱                                            
 1.9432446110793316ₜ  1.8969616956899726ₜ   1.821305434944808ₜ  1.9422426903783898ₜ     1.8130843992163226ₜ   1.925647431065683ₜ  1.9821156054755975ₜ
 1.8351228582124177ₜ  1.8476981796034435ₜ  1.8900126095774201ₜ  1.9265646192537365ₜ     1.8199132516271266ₜ  1.8965533201109692ₜ  1.8924960974984248ₜ
 1.9249231626771668ₜ  1.9297764269889721ₜ  1.8862700803360868ₜ   1.806926615060068ₜ      1.809062131744863ₜ  1.8901271541533395ₜ   1.886427277794776ₜ
 1.8072181108508338ₜ  1.9775066331853806ₜ  1.9123497718404443ₜ   1.836184950414772ₜ     1.7900098996910154ₜ   1.922259355287935ₜ  1.9914408174679352ₜ

julia> @profile for i in 1:10; A * B; end

julia> Profile.print(format=:flat,mincount=10)
 Count  Overhead File                          Line Function
 =====  ======== ====                          ==== ========
    12         0 REPL[16]                         1 +
    23         1 REPL[50]                         1 macro expansion
    23         0 REPL[50]                         1 top-level scope
    23         0 @Base/boot.jl                  430 eval
    23         0 @Base/client.jl                446 (::Base.var"#1150#1152"{Bool, Symbol, Bool})(REPL::Module)
    23         0 @Base/client.jl                541 _start()
    23         0 @Base/client.jl                567 repl_main
    23         0 @Base/client.jl                430 run_main_repl(interactive::Bool, quiet::Bool, banner::Symbol, history_file::Bool, color_s…
    23         0 @Base/essentials.jl           1055 #invokelatest#2
    23         0 @Base/essentials.jl           1052 invokelatest
    12         0 @Base/promotion.jl             633 muladd
    21         0 @Base/simdloop.jl               77 macro expansion
    22         0 @LinearAlgebra/src/matmul.jl   114 *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Float64}})
    22         0 @LinearAlgebra/src/matmul.jl   895 _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::Matrix{Tropical{Float64}}, B::Matrix…
    22         0 @LinearAlgebra/src/matmul.jl   287 _mul!
    22         0 @LinearAlgebra/src/matmul.jl   868 generic_matmatmul!
    21         0 @LinearAlgebra/src/matmul.jl   896 macro expansion
    22         0 @LinearAlgebra/src/matmul.jl   253 mul!
    22         0 @LinearAlgebra/src/matmul.jl   285 mul!
    23         0 @Profile/src/Profile.jl         59 macro expansion
    23         0 @REPL/src/REPL.jl              483 run_repl(repl::REPL.AbstractREPL, consumer::Any; backend_on_current_task::Bool, backend::…
    23         0 @REPL/src/REPL.jl              327 start_repl_backend(backend::REPL.REPLBackend, consumer::Any; get_module::Function)
    23         0 @REPL/src/REPL.jl              245 eval_user_input(ast::Any, backend::REPL.REPLBackend, mod::Module)
    23         0 @REPL/src/REPL.jl              342 repl_backend_loop(backend::REPL.REPLBackend, get_module::Function)
    23         0 @REPL/src/REPL.jl              469 run_repl(repl::REPL.AbstractREPL, consumer::Any)
    23         0 @REPL/src/REPL.jl              324 kwcall(::NamedTuple, ::typeof(REPL.start_repl_backend), backend::REPL.REPLBackend, consum…
Total snapshots: 23. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
```