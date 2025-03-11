# Homework 2

## Task 1: Open a Julia REPL, run the code above, and answer the following questions:
1. What are the outputs of the following expressions?
    ```bash
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
    - Type: ``Tropical{Float64}``
    - Supertypes: ``AbstractSemiring``, ``Number``, ``Any``
3. Is `Tropical` a concrete type or an abstract type?
   Concrete type.
4. Is `Tropical{Real}` a concrete type or an abstract type?
   Abstract type.
5. Benchmark and profile the performance of Tropical matrix multiplication:
   ```julia
   A = rand(Tropical{Float64}, 100, 100)
   B = rand(Tropical{Float64}, 100, 100)
   C = A * B   # please measure the time taken
   ```
   Write a brief report on the performance of the tropical matrix multiplication.
   ```Julia
    641.792 μs (3 allocations: 78.20 KiB)

    Count  Overhead File                                  Line Function
    =====  ======== ====                                  ==== ========
        10         0 @Base/abstractarray.jl                3048 _sub2ind
        10         0 @Base/abstractarray.jl                1347 _to_linear_index
        10         0 @Base/abstractarray.jl                  98 axes
        36         0 @Base/array.jl                         930 getindex
    458       458 @Base/array.jl                         994 setindex!
        32         0 @Base/array.jl                         372 similar
        10        10 @Base/array.jl                         194 size
        32         0 @Base/boot.jl                          582 Array
        32         0 @Base/boot.jl                          592 Array
        32        32 @Base/boot.jl                          516 GenericMemory
    577         0 @Base/boot.jl                          430 eval
        32         0 @Base/boot.jl                          535 new_as_memoryref
    577         0 @Base/essentials.jl                   1055 #invokelatest#2
    577         0 @Base/essentials.jl                   1055 invokelatest(::Any, ::Any, ::Vararg{Any}; kwargs::Bas…
        26        26 @Base/essentials.jl                    917 getindex
    577         0 @Base/essentials.jl                   1052 invokelatest(::Any)
        15        15 @Base/int.jl                            87 +
    577         0 @Base/loading.jl                      2734 include_string(mapexpr::typeof(REPL.softscope), mod::…
    577         0 @Base/logging/logging.jl               632 with_logger
    577         0 @Base/logging/logging.jl               522 with_logstate(f::VSCodeServer.var"#67#72"{Bool, Bool,…
        25        25 @Base/simdloop.jl                       75 macro expansion
    495         0 @Base/simdloop.jl                       77 macro expansion
        15         0 @Base/simdloop.jl                       78 macro expansion
    577         0 @LinearAlgebra/src/matmul.jl           114 *(A::Matrix{Tropical{Float64}}, B::Matrix{Tropical{Fl…
    535         0 @LinearAlgebra/src/matmul.jl           895 _generic_matmatmul!(C::Matrix{Tropical{Float64}}, A::…
    545         0 @LinearAlgebra/src/matmul.jl           287 _mul!
    545         0 @LinearAlgebra/src/matmul.jl           868 generic_matmatmul!
    495         0 @LinearAlgebra/src/matmul.jl           896 macro expansion
        32         0 @LinearAlgebra/src/matmul.jl           117 matprod_dest
    545         0 @LinearAlgebra/src/matmul.jl           253 mul!
    545         0 @LinearAlgebra/src/matmul.jl           285 mul!
    577         0 @Profile/src/Profile.jl                 59 macro expansion
    577         0 @VSCodeServer/src/eval.jl               34 (::VSCodeServer.var"#64#65")()
    577         0 @VSCodeServer/src/eval.jl              263 (::VSCodeServer.var"#66#71"{VSCodeServer.ReplRunCodeR…
    577         0 @VSCodeServer/src/eval.jl              150 #67
    577         0 @VSCodeServer/src/eval.jl              179 (::VSCodeServer.var"#68#73"{Bool, Bool, Bool, Module,…
    577         0 @VSCodeServer/src/eval.jl              181 (::VSCodeServer.var"#69#74"{Bool, Bool, Bool, Module,…
    577         0 @VSCodeServer/src/eval.jl              271 inlineeval(m::Module, code::String, code_line::Int64,…
    577         0 @VSCodeServer/src/eval.jl              268 kwcall(::@NamedTuple{softscope::Bool}, ::typeof(VSCod…
    577         0 @VSCodeServer/src/repl.jl               38 hideprompt(f::VSCodeServer.var"#68#73"{Bool, Bool, Bo…
    577         0 @VSCodeServer/src/repl.jl              276 withpath(f::VSCodeServer.var"#69#74"{Bool, Bool, Bool…
    577         0 …meworks/hw2/huanhaizhou/tropical.jl   103 macro expansion
    577         0 …meworks/hw2/huanhaizhou/tropical.jl   103 top-level scope
    Total snapshots: 580. Utilization: 100% across all threads and tasks. Use the `groupby` kwarg to break down by thread and/or task.
    ```
    Profiling shows most time spent in matrix multiplication and macro expansions.

## Task 2: Implement the the following semiring algebra over sets:

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