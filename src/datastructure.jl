"""
    Node(k::Int64, T::Vector{Int64}, H::Vector{Int64})

A `Node` is a point on the graph with index `k`, predecessor
nodes `T`, and successor nodes `H`.
"""
struct Node
    k::Int64                                # Node index
    T::Vector{Int64}                        # Predecessor nodes (tail node indices)
    H::Vector{Int64}                        # Successor nodes (head node indices)
end

"""
    Origin(n::Node, k::Int64, S::Vector{Node}, Q::Vector{Float64}, L::Vector{Int64})

An `Origin` node represent node `n` on the graph with origin
node index `k`, destination nodes `S`, flows `Q`, and predecessor
label `L`.
"""
struct Origin
    n::Node                                 # Origin node
    k::Int64                                # Origin node index in vector G.O; k = findfirst(x -> (x == o), O)
    S::Vector{Node}                         # Vector of destination nodes
    Q::Vector{Float64}                      # Vector of flows   
    L::Vector{Int64}                        # Predecessor label
end

"""
    Destination(n::Node, k::Int64, R::Vector{Node}, Q::Vector{Float64}, L::Vector{Int64})

An `Destination` node represent node `n` on the graph with 
destination node index `k`, origin nodes `R`, flows `Q`, and 
successor label `L`.
"""
struct Destination
    n::Node                                 # Destination node
    k::Int64                                # Destination node index in vector G.D; k = findfirst(x -> (x == d), D)
    R::Vector{Node}                         # Vector of origin nodes
    Q::Vector{Float64}                      # Vector of flows   
    L::Vector{Int64}                        # Successor label
end

"""
    Arc(t::Node, h::Node, v::Float64, d::Float64, tₒ::Float64, α::Float64, β::Float64, x::Float64, Xʳ::Vector{Float64}, c::Float64, c′::Float64)

An `Arc` is a connection between tail node `t` and head node
`h` with a volume capacity of `v`, length `d`, free flow
travel time `tₒ`, BPR parameters `α` and `β`, arc flow `x`,
origin based arc flows `Xʳ`, cost `c`, and cost derivative `c`
"""
mutable struct Arc
    t::Node                                 # Tail node (From)
    h::Node                                 # Head node (To)
    v::Float64                              # Volume capacity of the arc
    d::Float64                              # Length of the arc
    tₒ::Float64                             # Free flow travel time on the arc
    α::Float64                              # BPR parameter
    β::Float64                              # BPR parameter
    x::Float64                              # Arc flow
    Xʳ::Vector{Float64}                     # Origin based arc flow
    c::Float64                              # Arc cost
    c′::Float64                             # Arc cost derivative
end

"""
    PAS(e₁::Vector{Arc}, e₂::Vector{Arc}, o::Origin)

A `PAS` is a paired alternative segment with `e₁` as the
first segment and `e₂` as the second segment with an associated
origin `o`.
"""
struct PAS
    e₁::Vector{Arc}                         # First segment
    e₂::Vector{Arc}                         # Second segment
    o::Origin                               # Assosciated origin
end

"""
    Graph(name::String, N::Vector{Node}, A::Vector{Arc}, K::Dict{Tuple{Int64, Int64}, Int64}, O::Vector{Origin}, D::Vector{Destination})

A `Graph` is a representation of network `name` with nodes
`N`, arcs `A`, arc indices `K`, origins `O`, and destinations
`D`.
"""
struct Graph
    name::String                            # Network name
    N::Vector{Node}                         # Vector of nodes 
    A::Vector{Arc}                          # Vector of arcs
    K::Dict{Tuple{Int64, Int64}, Int64}     # Collection of arc indices mapped to tuple of arc head and tail node value (one to one mapping - (i,j) => findfirst(x -> (x == (i,j)), [(a.t.i, a.h.i) for a in A]))
    O::Vector{Origin}                       # Vector of origins
    D::Vector{Destination}                  # Vector of destinations
end

function Base.:∈(pₒ::PAS, P::Vector{PAS})
    for p in P if pₒ.e₁ == p.e₁ && pₒ.e₂ == p.e₂ return true end end
    return false
end
Base.:∉(pₒ::PAS, P::Vector{PAS}) = !(Base.:∈(pₒ, P))