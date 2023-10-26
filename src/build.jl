"""
    build(network, assignment)

Returns network as a graph with nodes, arcs, and relevant properties, for `:UE` or `:SO` assignment
"""
function build(network, assignment)
    ϕ = assignment == :UE ? false : true

    # csv files
    df₁ = DataFrame(CSV.File(joinpath(dirname(@__DIR__), "network/$network/network.csv"), types=[Int64, Int64, Float64, Float64, Float64, Float64, Float64]))
    df₂ = DataFrame(CSV.File(joinpath(dirname(@__DIR__), "network/$network/demand.csv")))

    # Nodes
    N = Vector{Node}(undef, max(maximum(df₁[!,1]), maximum(df₁[!,2])))
    T = [Int64[] for _ ∈ eachindex(N)]
    H = [Int64[] for _ ∈ eachindex(N)]
    for k ∈ 1:nrow(df₁)
        i = df₁[k,1]
        j = df₁[k,2]
        push!(H[i], j)
        push!(T[j], i)
    end
    for k ∈ eachindex(N)
        n = Node(k, T[k], H[k])
        N[k] = n
    end
    
    # Arcs
    A  = Vector{Arc}(undef, nrow(df₁))  
    Xʳ = zeros(nrow(df₂))
    for k in 1:nrow(df₁)
        i = df₁[k,1]
        j = df₁[k,2]
        t = N[i]
        h = N[j]
        v = df₁[k,3]
        d = df₁[k,4]
        tₒ= df₁[k,5]
        α = df₁[k,6]
        β = df₁[k,7]
        a = Arc(t, h, v, d, tₒ, α, β, 0., copy(Xʳ), 0., 0., ϕ)
        A[k] = a
    end

    # Index mapping
    K = Dict((df₁[k,1], df₁[k,2]) => k for k ∈ 1:nrow(df₁))

    # Origins
    R = N[unique(df₂[!,1])]
    L = Vector{Int64}(undef, length(N))
    O = Vector{Origin}(undef, length(R))
    S = [Node[] for _ ∈ eachindex(R)]
    Q = [Float64[] for _ ∈ eachindex(R)]
    for k ∈ 1:nrow(df₂)
        i = df₂[k,1]
        j = df₂[k,2]
        q = df₂[k,3]
        r = N[i]
        s = N[j]
        k = findfirst(x -> (x == r), R)
        push!(S[k], s)
        push!(Q[k], q)
    end
    for k ∈ eachindex(O)
        r = R[k]
        o = Origin(r, k, S[k], Q[k], copy(L))
        O[k] = o
    end

    # Destinations
    S = N[unique(df₁[!,2])]
    L = Vector{Int64}(undef, length(N))
    D = Vector{Destination}(undef, length(S))
    R = [Node[] for _ ∈ eachindex(S)]
    Q = [Float64[] for _ ∈ eachindex(S)]
    for k ∈ 1:nrow(df₂)
        i = df₂[k,1]
        j = df₂[k,2]
        q = df₂[k,3]
        r = N[i]
        s = N[j]
        k = findfirst(x -> (x == s), S)
        push!(R[k], r)
        push!(Q[k], q)
    end
    for k ∈ eachindex(D)
        s = S[k]
        d = Destination(s, k, R[k], Q[k], copy(L))
        D[k] = d
    end

    G = Graph(network, N, A, K, O, D)
    return G
end