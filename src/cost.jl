"""
    cₐ(a::Arc, x=a.x)

Returns arc cost for arc `a` for arc flow `x`
"""
function cₐ(a::Arc, x=a.x)
    φ = ϕ::Bool
    tₒ= a.tₒ
    α = a.α
    β = a.β
    v = a.v

    t = tₒ * (1 + α * (x/v) ^ β)
    t′= iszero(φ) || iszero(β) ? 0. : tₒ * α * β * (x ^ (β - 1))/(v ^ β)
    
    c = t + φ * x * t′

    return c
end

"""
    cₑ(e::Vector{Arc})

Returns segment cost for segment `e`
"""
function cₑ(e::Vector{Arc})
    c = 0.
    for a in e c += a.c end
    return c
end

"""
    cₐ′(a::Arc, x=a.x)

Returns first derivative of arc cost wrt arc flow for arc `a` at arc flow `x`
"""
function cₐ′(a::Arc, x=a.x)
    φ = ϕ::Bool
    tₒ= a.tₒ
    α = a.α
    β = a.β
    v = a.v

    t′= iszero(β) ? 0. : tₒ * α * β * (x ^ (β - 1))/(v ^ β)
    t″ = iszero(φ) || iszero(β) || isone(β) ?  0. : tₒ * α * β * (β - 1) * (x ^ (β - 2))/(v ^ β)
    
    c′ = t′ + φ * x * t″
    return c′
end

"""
    cₑ′(e::Vector{Arc})

Returns first derivative of segment cost for segment `e`
"""
function cₑ′(e::Vector{Arc})
    c′ = 0.
    for a in e c′ += a.c′ end
    return c′
end