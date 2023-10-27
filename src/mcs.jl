"""
    fₑ(e::Vector{Arc}, o::Origin)

Return minimum flow on segment `e` from origin `o`
"""
function fₑ(e::Vector{Arc}, o::Origin)
    f = Inf
    k = o.k
    for a ∈ e if a.Xʳ[k] < f f = a.Xʳ[k] end end
    return f
end

"""
    ispotential(a::Arc, o::Origin, G::Graph)

Identfies if arc `a` on graph `G` is a potential arc wrt flow from origin `o`
"""
function ispotential(a::Arc, o::Origin, G::Graph)
    k   = o.k
    xʳₐ = a.Xʳ[k]
    cₜₕ = a.c

    t   = a.t
    pᵣₜ = path(G, o, t)
    uʳₜ = 0.
    for a ∈ pᵣₜ uʳₜ += a.c end
    
    h = a.h
    pᵣₕ = path(G, o, h)
    uʳₕ = 0.
    for a ∈ pᵣₕ uʳₕ += a.c end
    
    πʳₐ = uʳₜ + cₜₕ - uʳₕ 

    bool = xʳₐ > 1e-12 && πʳₐ > 1e-16

    return bool
end

"""
    𝝳(p::PAS, λ)

Evaluates amount of flow `δ` to shift on pas `p`.
If `δ` is less than the threshold limit of `λ` then `δ` is assumed to be zero.
"""
function 𝝳(p::PAS, λ)
    e₁, e₂, o = p.e₁, p.e₂, p.o
    
    f₁, f₂   = fₑ(e₁, o), fₑ(e₂, o)
    c₁, c₂   = cₑ(e₁), cₑ(e₂)
    c₁′, c₂′ = cₑ′(e₁), cₑ′(e₂)
    
    Δ = (c₂ - c₁)/(c₁′ + c₂′)
    
    if abs(c₂ - c₁) < λ δ = 0. end
    if isnan(Δ) δ = 0.
    elseif Δ ≥ 0 δ = min(Δ, f₂)
    else δ = max(Δ, -f₁)
    end

    return δ
end

"""
    shift(p::PAS, δ)

Shifts flow `δ` on pas `p`.
"""
function shift(p::PAS, δ)
    e₁, e₂, o = p.e₁, p.e₂, p.o
    k = o.k
    
    for a ∈ e₁
        a.Xʳ[k] += δ
        a.x += δ
        a.c = cₐ(a)
        a.c′= cₐ′(a)
    end

    for a ∈ e₂
        a.Xʳ[k] -= δ
        a.x -= δ
        a.c = cₐ(a)
        a.c′= cₐ′(a)
    end
    
    return
end

"""
    MCS(a::Arc, o::Origin, G::Graph)

Develops pas for arc `a` wrt origin `o` using Maximum Cost Search method
"""
function MCS(a::Arc, o::Origin, G::Graph)
    depth, maxdepth = 1, 2
    
    t, h = a.t, a.h
    i, j = t.k, h.k
    r, L₁ = o.n, o.L
    N, A, K = G.N, G.A, G.K
    
    pᵣₕ = path(G, L₁, r, a.h)
    
    s = 1
    p = PAS(Arc[], Arc[], o)
    
    
    while depth ≤ maxdepth
        # Intialize
        l = zeros(Int64, length(N))
        for a ∈ pᵣₕ
            t = a.t
            k = t.k
            l[k] = -1 
        end
        l[i] = 1
        l[j] = 1

        L₂ = Vector{Int64}(undef, length(N))
        L₂[j] = K[i,j]
        
        # Iterate
        t, h = a.t, a.h
        while true
            h = t
            
            # Maximum Cost Search
            f = 0.
            for n ∈ h.T 
                k = K[n,h.k]
                x = A[k].Xʳ[o.k]
                c = A[k].c
                if x > 1e-12 && c > f 
                    f = c
                    t = N[n]
                    L₂[h.k] = k
                end
            end
            
            # PAS found
            if isone(-l[t.k])
                e₁ = path(G, L₁, t, a.h)
                e₂ = path(G, L₂, t, a.h)
 
                s = l[t.k]
                p = PAS(e₁, e₂, o)

                δ = 𝝳(p, 0.)
                shift(p, δ)
                bool = ispotential(a, o, G)
                if !bool
                    return s, p
                else
                    depth += 1
                    break
                end
            # Cycle found
            elseif isone(l[t.k])
                if depth < maxdepth
                    pₕₜ = path(G, L₂, h, t)
                    if h != t push!(pₕₜ, A[K[t.k, h.k]]) end
                    δ = Inf
                    k = o.k
                    for a ∈ pₕₜ if a.Xʳ[k] ≤ δ δ = a.Xʳ[k] end end
                    for a ∈ pₕₜ 
                        a.Xʳ[k] -= δ
                        a.x -= δ
                        a.c = cₐ(a)
                        a.c′= cₐ′(a)
                    end
                end
                depth += 1
                break
            # Continue
            else l[t.k] = 1
            end
        end
    end

    return s, p
end