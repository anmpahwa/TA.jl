"""
    djk(G::Graph, o::Origin)

Djikstra's label setting algorithm.
Returns predecessor arc label (index in vector `A`) `L` for least cost paths from origin `o` on graph `G`.
"""
function djk(G::Graph, o::Origin)
    N = G.N
    A = G.A
    K = G.K
    r = o.n

    P = zeros(Int64, length(N))             # Predecessor label
    C = fill(Inf, length(N))                # Cost label
    X = copy(N)                             # Set of open nodes

    t = r
    k = t.k
    P[k] = -1
    C[k] = 0.
    deleteat!(X, k)
    while !isempty(X)
        i = t.k
        for j ∈ t.H
            k = K[i,j]
            a = A[k]
            c = C[i] + a.c
            if c < C[j] && N[j] ∈ X P[j], C[j] = k, c end
        end
        k = argmin([C[n.k] for n ∈ X])
        t = X[k]
        deleteat!(X, k)
    end
    
    return P
end

"""
    djk(G::Graph, d::Destination)

Djikstra's label setting algorithm.
Returns successor arc label (index in vector `A`) `L` for least cost paths to destination `d` on graph `G`.
"""
function djk(G::Graph, d::Destination)
    N = G.N
    A = G.A
    K = G.K
    s = d.n

    S = zeros(Int64, length(N))             # Successor label
    C = fill(Inf, length(N))                # Cost label
    X = copy(N)                             # Set of open nodes

    h = s
    k = t.k
    S[k] = -1
    C[k] = 0.
    deleteat!(X, k)
    while !isempty(X)
        j = h.k
        for i ∈ h.T
            k = K[i,j]
            a = A[k]
            c = C[i] + a.c
            if c < C[j] && N[j] ∈ X S[j], C[j] = k, c end
        end
        k = argmin([C[n.k] for n ∈ X])
        h = X[k]
        deleteat!(X, k)
    end

    return S
end

"""
    tree(G::Graph, o::Origin)

Returns tree for graph `G` rooted from origin `o`
"""
function tree(G::Graph, o::Origin)
    N = G.N
    A = G.A
    L = o.L

    T = [Node[] for _ ∈ eachindex(N)]

    for k ∈ L
        if isone(-k) continue end
        a = A[k]
        t = a.t
        h = a.h
        k = t.k
        push!(T[k], h)
    end

    return T
end

"""
    tree(G::Graph, d::Destination)

Returns tree for graph `G` rooted to destination `d`
"""
function tree(G::Graph, d::Destination)
    N = G.N
    A = G.A
    L = d.L

    H = [Node[] for _ ∈ eachindex(N)]

    for k ∈ L
        if isone(-k) continue end
        a = A[k]
        t = a.t
        h = a.h
        k = h.k
        push!(H[k], t)
    end

    return H
end

"""
path(G::Graph, L::Vector{Int64}, r::Node, s::Node)

Returns path between origin node `r` and destination  node `s` on graph `G` using predecessor label `L`
"""
function path(G::Graph, L::Vector{Int64}, r::Node, s::Node)
    A = G.A
    
    p = Arc[]

    h = s
    j = h.k
    while !isequal(j, r.k)
        k = L[j]
        a = A[k]
        push!(p, a)
        t = a.t
        j = t.k
    end

    reverse!(p)

    return p
end
"""
path(G::Graph, r::Node, s::Node, L::Vector{Int64})

Returns path between origin node `r` and destination  node `s` on graph `G` using successor label `L`
"""
function path(G::Graph, r::Node, s::Node, L::Vector{Int64})
    A = G.A
    
    p = Arc[]

    t = r
    i = t.k
    while !isequal(j, s.k)
        k = L[i]
        a = A[k]
        push!(p, a)
        h = a.h
        i = h.k
    end

    return p
end
path(G::Graph, r::Node, d::Destination)   = path(G::Graph, d.L, r, d.n)
path(G::Graph, o::Origin, s::Node)        = path(G::Graph, o.L, o.n, s)
path(G::Graph, o::Origin, d::Destination) = path(G::Graph, o.L, o.n, d.n)