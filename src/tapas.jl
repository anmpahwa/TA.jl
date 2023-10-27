include("mcs.jl")

"""
    tapas(G::Graph, tol, maxiters, maxruntime, log::Symbol)

Paired Alternative Segments algorithm for static single-class traffic assignment problem with generalized link cost function.

# Returns
a named tuple with keys `:metadata`, `:report`, and `:output`
- `metadata::String`  : Text defining the traffic assignment run 
- `report::DataFrame` : A log of total network flow, total network cost, and run time for every iteration
- `output::DataFrame` : Flow and cost for every arc from the final iteration

# Arguments
- `G::Graph`            : Network structure as `Graph`
- `tol::Float64`        : Tolerance level for relative gap
- `maxiters::Int64`     : Maximum number of iterations
- `maxruntime::Int64`   : Maximum algorithm run time (seconds)
- `log::Symbol`         : Log iterations (one of `:off`, `:on`)
"""
function tapas(G::Graph, tol, maxiters, maxruntime, log::Symbol)
    report   = DataFrame(LOG₁₀RG = Float64[], TF = Float64[], TC = Float64[], RT = Float64[])
    solution = DataFrame(FROM = Int64[], TO = Int64[], FLOW = Float64[], COST = Float64[])
    
    A, O = G.A, G.O                                                         # Graph
    P  = PAS[]                                                              # PASs
    
    if isequal(log, :on)
        print("\n iter  | logRG      | TF          | TC          | RT (s) ")
        print("\n ------|------------|-------------|-------------|--------")
    end
    
    # Intialize
    tₒ = now() 
    n = 0
    for a ∈ A 
        a.c = cₐ(a)
        a.c′= cₐ′(a)
    end 
    for (i,o) ∈ enumerate(O)
        r = o.n
        L = djk(G, o)
        o.L .= L
        for (j,s) ∈ enumerate(o.S)
            qᵣₛ = o.Q[j]
            pᵣₛ = path(G, L, r, s)
            for a ∈ pᵣₛ
                a.Xʳ[i] += qᵣₛ
                a.x += qᵣₛ
                a.c = cₐ(a)
            end
        end
    end

    # Iterate
    z = zeros(4)
    while true
        # Relative gap
        num, den = 0., 0.
        for o ∈ O
            r = o.n
            L = djk(G, o)
            o.L .= L
            for (k,s) ∈ enumerate(o.S)
                qᵣₛ = o.Q[k]
                pᵣₛ = path(G, L, r, s)
                for a ∈ pᵣₛ num += qᵣₛ * a.c end
            end
        end
        for a ∈ A den += a.x * a.c end
        rg = 1 - num/den
        
        # Total flow
        tf = 0.
        for a ∈ A tf += a.x end

        # Total cost
        tc = 0.
        for a ∈ A tc += a.x * a.c end

        # Run time
        tₙ = now()
        runtime = (tₙ - tₒ).value/1000
        
        z .= log10(abs(rg)), tf, tc, runtime
        push!(report, z)
        
        if isequal(log, :on) @printf("\n #%02i   | %.3e | %.5e | %.5e | %.3f ", n, z...) end

        if log10(abs(rg)) ≤ log10(tol) || n ≥ maxiters || runtime ≥ maxruntime break end

        n += 1

        # Indentify potential arc => Find PAS for this arc => Perform flow shift on this PAS
        for o ∈ O
            L = djk(G, o)
            o.L .= L            
            T = tree(G, o)
            for a ∈ A
                t = a.t
                h = a.h
                if h ∈ T[t.k] continue end
                bool = ispotential(a, o, G)
                if bool
                    s, p = MCS(a, o, G)
                    if isone(-s) && p ∉ P push!(P, p) end
                end
            end
            # Local shift for faster convergence
            for p in sample(P, length(P) ÷ 4) 
                δ = 𝝳(p, rg/1000)
                shift(p, δ)  
            end
        end
        
        # PAS removal
        for _ in 1:40
            for (m,p) ∈ enumerate(P)
                e₁, e₂, o = p.e₁, p.e₂, p.o
                f₁, f₂ = fₑ(e₁, o), fₑ(e₂, o)
                c₁, c₂ = cₑ(e₁), cₑ(e₂)
                bool = (f₁ < 1e-12 || f₂ < 1e-12) && (c₁ ≠ c₂)
                if bool deleteat!(P, m)
                else shift(p, 𝝳(p, rg/1000)) 
                end
            end
        end
    end
    
    for a ∈ A
        t, h = a.t, a.h
        z .= t.k, h.k, a.x, a.c
        push!(solution, z) 
    end

    φ = ϕ::Bool
    assignment = φ ? :UE : :SO
    
    metadata = "MetaData
    Network     => $(G.name)
    assignment  => $(String(assignment))
    method      => Pure Frank-Wolfe"

    return (metadata = metadata, report = report, solution = solution)
end