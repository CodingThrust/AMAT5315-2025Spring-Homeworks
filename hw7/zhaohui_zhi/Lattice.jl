function triangle(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0.5, 0.5*sqrt(3))
    sites = vec([50 .*(a .* i .+ b .* j) for i=1:Na, j=1:Nb])

    graph = ProblemReductions.UnitDiskGraph(vec(sites), 55.0)
    g = SimpleGraph(graph)
    return g
end

function squares(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0, 1)
    sites = vec([50 .*(a .* i .+ b .* j) for i=1:Na, j=1:Nb])

    graph = ProblemReductions.UnitDiskGraph(vec(sites), 50.0)
    g = SimpleGraph(graph)
    return g
end

function diamonds(Na::Int64, Nb::Int64)
    a, b = (1, 0), (0, 1)
    sites = vec([50 .* (a .* (j % 2 == 0 ? 2*i-1 : 2*i) .+ b .* j) for i=1:Na, j=1:Nb])

    sites=vcat(sites, [50 .* (a .* (2*Na+1) .+b .*(j)) for j=2:2:Nb])

    graph = ProblemReductions.UnitDiskGraph(vec(sites), 50.0*√2)
    g = SimpleGraph(graph)
    return g
    
end
