# Test the transfer matrix
using ProblemReductions, Graphs, Test
include("method.jl")
function transition_matrix(model::SpinGlass, beta::T) where {T}
    N = num_variables(model)
    P = zeros(T, 2^N, 2^N)  # P[i, j] = probability of transitioning from j to i
    readbit(cfg, i::Int) = (cfg >> (i - 1)) & 1  # read the i-th bit of cfg
    int2cfg(cfg::Int) = [readbit(cfg, i) for i = 1:N]
    for j = 1:(2^N)
        for i = 1:(2^N)
            if count_ones((i-1) ⊻ (j-1)) == 1  # Hamming distance is 1
                P[i, j] =
                    1/N * min(
                        one(T),
                        exp(
                            -beta *
                            (energy(model, int2cfg(i-1)) - energy(model, int2cfg(j-1))),
                        ),
                    )
            end
        end
        P[j, j] = 1 - sum(P[:, j])  # rejected transitions
    end
    return P
end

@testset "Test the transfer matrix in 'method.jl'" begin
    graph = Graphs.cycle_graph(6)
    model = SpinGlass(graph, -ones(ne(graph)), zeros(nv(graph)))
    T = 1.0
    P0 = transition_matrix(model, T)
    P1 = generate_trans(adjacency_matrix(graph), T)

    @test norm(P0 - P1) < 1e-12
end
