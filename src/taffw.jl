"""
    taffw(G::Graph, tol, maxiters, maxruntime, log::Symbol)

Fukushima Frank-Wolfe method for static multi-class traffic assignment problem with generalized link cost function.

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
function taffw(G::Graph, tol, maxiters, maxruntime, log::Symbol)
    report   = DataFrame(LOG₁₀RG = Float64[], TF = Float64[], TC = Float64[], RT = Float64[])
    solution = DataFrame(FROM = Int64[], TO = Int64[], FLOW = Float64[], COST = Float64[])

    A, K, O = G.N, G.A, G.K, G.O                                            # Graph  
    y  = zeros(length(A))                                                   # Auxiliary arc flow
    p  = zeros(length(A))                                                   # Point of sight
    d  = zeros(length(A))                                                   # Search direction
    Y  = [zeros(length(A)) for _ ∈ 1:maxiters]                              # Auxiliary link flows from each iteration (for Fukushima FW)
    P  = [zeros(length(A)) for _ ∈ 1:maxiters]                              # Point of sight from each iteration (for Conjugate FW)
    
     if log == :on
        print("\n iter  | LOG₁₀(RG)  | TF          | TC          |  RT (s)")
        print("\n ------|------------|-------------|-------------|--------")
    end

    # Intializate
    tₒ = now() 
    n  = 0
    for a ∈ A a.c = cₐ(a) end
    for (i,o) ∈ enumerate(O)
        r = o.n
        L = djk(G, o)
        o.L .= L
        for (j,s) ∈ enumerate(o.S)
            qᵣₛ = o.Q[j]
            pᵣₛ = path(G, L, r, s)
            for a in pᵣₛ
                a.x += qᵣₛ
                a.c = cₐ(a)
            end
        end
    end
    
    # Iterate
    z = zeros(4)
    while true
        # Relative gap
        num, den = 0.0, 0.0
        for (i,o) ∈ enumerate(O)
            r = o.n
            L = djk(G, o)
            o.L .= L
            for (j,s) ∈ enumerate(o.S)
                qᵣₛ = o.Q[j]
                pᵣₛ = path(G, L, r, s)
                for a in pᵣₛ num += qᵣₛ * a.c end
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

        # Auxilary problem
        for (k,a) ∈ enumerate(A) y[k] = 0.0 end
        for (i,o) ∈ enumerate(O)
            r = o.n
            L = o.L
            for (j,s) ∈ enumerate(o.S)
                qᵣₛ = o.Q[j]
                pᵣₛ = path(G, L, r, s)
                for a in pᵣₛ
                    k = K[a.t.k, a.h.k]
                    y[k] += qᵣₛ
                end
            end
        end

        # Point of sight
        λ = 0.5
        yₙ = y
        yₙ₋₁ = isone(n) ? yₙ : Y[n-1]
        for (k,a) ∈ enumerate(A) p[k] = λ * yₙ₋₁[k] + (1 - λ) * yₙ[k] end

        # Seach direction
        for (k,a) ∈ enumerate(A) d[k] = p[k] - a.x end
        
        # Line search
        ε = 0.01
        l = 0.
        u = 1.
        α = (l + u)/2
        while abs(u-l) ≥ ε
            v = 0.
            for (k,a) ∈ enumerate(A) 
                x = a.x + α * d[k]
                v += cₐ(a, x) * d[k] 
            end            
            if v < 0. l = α
            elseif v > 0. u = α
            else break
            end
            α = (l + u)/2
        end

        # Update
        for (k,a) ∈ enumerate(A) 
            a.x += α * d[k]
            a.c = cₐ(a)
        end
        Y[n] = deepcopy(y)
        P[n] = deepcopy(p)
    end

    for a ∈ A
        t, h = a.t, a.h
        z .= t.k, h.k, sum(a.Xʳ), a.c
        push!(solution, z) 
    end
    
    φ = ϕ::Bool
    assignment = φ ? :UE : :SO

    metadata =  "MetaData
    Network     => $(G.name)
    assignment  => $(String(assignment))
    method      => Fukushima FrankWolfe"
    
    return (metadata = metadata, report = report, solution = solution)
end