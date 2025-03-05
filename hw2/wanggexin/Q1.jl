using Random
abstract type AbstractSemiring <: Number end

# define the -inf
neginf(::Type{T}) where T = typemin(T)
neginf(::Type{T}) where T<:AbstractFloat = typemin(T)
neginf(::Type{T}) where T<:Rational = typemin(T)
neginf(::Type{T}) where T<:Integer = T(-999999)
neginf(::Type{Int16}) = Int16(-16384)
neginf(::Type{Int8}) = Int8(-64)
posinf(::Type{T}) where T = - neginf(T)

struct Tropical{T} <: AbstractSemiring
    n::T
    Tropical{T}(x) where T = new{T}(T(x))
    function Tropical(x::T) where T
        new{T}(x)
    end
    function Tropical{T}(x::Tropical{T}) where T
        x
    end
    function Tropical{T1}(x::Tropical{T2}) where {T1,T2}
        # new is the default constructor
        new{T1}(T2(x.n))
    end
end

# customize the print
Base.show(io::IO, t::Tropical) = Base.print(io, "$(t.n)ₜ")

# power is mapped to multiplication
Base.:^(a::Tropical, b::Real) = Tropical(a.n * b)
Base.:^(a::Tropical, b::Integer) = Tropical(a.n * b)

# multiplication is mapped to addition
Base.:*(a::Tropical, b::Tropical) = Tropical(a.n + b.n)
function Base.:*(a::Tropical{<:Rational}, b::Tropical{<:Rational})
    if a.n.den == 0
        a
    elseif b.n.den == 0
        b
    else
        Tropical(a.n + b.n)
    end
end

# addition is mapped to max
Base.:+(a::Tropical, b::Tropical) = Tropical(max(a.n, b.n))

# minimum value of the semiring
Base.typemin(::Type{Tropical{T}}) where T = Tropical(neginf(T))

# additive identity (zero element) - defined on types
Base.zero(::Type{Tropical{T}}) where T = typemin(Tropical{T})
# additive identity (zero element)
Base.zero(::Tropical{T}) where T = zero(Tropical{T})

# multiplicative identity (one element)
Base.one(::Type{Tropical{T}}) where T = Tropical(zero(T))
Base.one(::Tropical{T}) where T = one(Tropical{T})

# inverse is mapped to negative
Base.inv(x::Tropical) = Tropical(-x.n)

# division is mapped to subtraction
Base.:/(x::Tropical, y::Tropical) = Tropical(x.n - y.n)
# `div` is similar to `/`, the only difference is that `div(::Int, ::Int) -> Int`, but `/(::Int, ::Int) -> Float64`
Base.div(x::Tropical, y::Tropical) = Tropical(x.n - y.n)

# two numbers are approximately equal. For floating point numbers, this is often preferred to `==` due to the rounding error.
Base.isapprox(x::Tropical, y::Tropical; kwargs...) = isapprox(x.n, y.n; kwargs...)

# promotion rules
Base.promote_type(::Type{Tropical{T1}}, b::Type{Tropical{T2}}) where {T1, T2} = Tropical{promote_type(T1,T2)}

function Random.rand(rng::AbstractRNG, ::Random.SamplerType{Tropical{T}}) where T
    Tropical{T}(rand(rng, T))
end



# julia> Tropical(1.0) + Tropical(3.0)
# 3.0ₜ

# julia> Tropical(1.0) * Tropical(3.0)
# 4.0ₜ

# julia> one(Tropical{Float64})
# 0.0ₜ

# julia> zero(Tropical{Float64})
# -Infₜ
using Pkg
Pkg.add(["BenchmarkTools", "ProfileView"])

using Random, BenchmarkTools

@btime A = rand(Tropical{Float64}, 100, 100)


# 1 dependency successfully precompiled in 2 seconds. 359 already precompiled.
# 9.784 μs (3 allocations: 78.20 KiB)






# 100×100 Matrix{Tropical{Float64}}:
# 0.7644172167580878ₜ    0.4247407186469466ₜ   0.8402862370457943ₜ  …   0.3602624425542219ₜ   0.7278964002724153ₜ   0.16126825692963442ₜ
# 0.48132751632930015ₜ    0.7974509438935976ₜ   0.3878071276309074ₜ      0.8145417185242398ₜ   0.2869720697184943ₜ   0.07305883131406865ₜ
# 0.48016846374771516ₜ    0.4468626897121064ₜ   0.6372194193447253ₜ     0.17998638265294586ₜ  0.17289302228789494ₜ    0.9960680742199685ₜ
# 0.3875786064267417ₜ    0.2081762245504435ₜ   0.1348037327924353ₜ     0.29644000432779605ₜ   0.7273399531939702ₜ   0.08769947872956962ₜ
# 0.3743790379820129ₜ    0.2054268850215456ₜ  0.10624443201940759ₜ     0.22058317470483335ₜ   0.2126394803329973ₜ    0.7987028839996151ₜ
# 0.4118501268872131ₜ    0.2395540396643191ₜ  0.14775751682504734ₜ  …   0.9248746867614199ₜ  0.09651157054845871ₜ    0.9950787976945661ₜ
# 0.6470853690074251ₜ    0.3407822038494457ₜ   0.7935229106077437ₜ      0.9935378659360109ₜ  0.07484953484530243ₜ   0.24866889384104096ₜ
# 0.3161355136899572ₜ    0.7246168834051617ₜ  0.02306031202703407ₜ     0.04016688754639097ₜ   0.9734328538702375ₜ   0.32472655587706845ₜ
# 0.14477832300707305ₜ    0.7665077794263563ₜ  0.26093437060120594ₜ      0.2065864337408967ₜ   0.8908772478306998ₜ   0.43727739808341515ₜ
#                   ⋮                                               ⋱                                              
# 0.5360444281090126ₜ    0.6321663228687875ₜ   0.4055282676676858ₜ      0.9959648791046324ₜ   0.5078978201686102ₜ   0.24743212307271545ₜ
# 0.9080634041578189ₜ   0.41885542241606766ₜ   0.1709657484521503ₜ      0.9955280566628324ₜ    0.775561958937165ₜ    0.8886001224813429ₜ
# 0.32679854665808705ₜ   0.10001788838600156ₜ   0.8078826169171386ₜ      0.7966770746758913ₜ   0.6879801915588779ₜ    0.5448740247879312ₜ
# 0.25228729952783224ₜ     0.521300253061419ₜ    0.307913823679551ₜ      0.7123001765575188ₜ   0.2542350291173533ₜ  0.012271100383718259ₜ
# 0.9978413474821747ₜ    0.5471244707844619ₜ  0.35312108210876947ₜ  …  0.18776515937279625ₜ   0.6401018549892872ₜ    0.8951861372747075ₜ
# 0.6542543085110916ₜ      0.55619424913428ₜ   0.6327765674565945ₜ      0.5290233598310438ₜ  0.15608394929999103ₜ    0.8698503617870744ₜ
# 0.5181139941269467ₜ  0.025746509947982443ₜ   0.7598389745988099ₜ      0.7025563620224731ₜ  0.19711222374835846ₜ    0.8567247171731067ₜ
# 0.2951331443284959ₜ   0.24763744764720408ₜ   0.5487079259462966ₜ      0.6164911509373846ₜ    0.747104560055215ₜ    0.9924698772978512ₜ
# 0.6913611463452695ₜ    0.5327008259405509ₜ   0.6294320353741217ₜ     0.39166374701285644ₜ   0.9873112025475731ₜ    0.1858302488369704ₜ