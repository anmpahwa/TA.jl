include("tapfw.jl")
include("taffw.jl")
include("tacfw.jl")
include("tapas.jl")

"""
    assigntraffic(; method, network, assignment=:UE, tol=1e-5, maxiters=20, maxruntime=300, log=:off)

Traffic Assignment

# Returns
a named tuple with keys `:metadata`, `:report`, and `:output`
- `metadata::String`  : Text defining the traffic assignment run 
- `report::DataFrame` : A log of total network flow, total network cost, and run time for every iteration
- `output::DataFrame` : Flow and cost for every arc from the final iteration

# Arguments
- `method::Symbol`          : One of `:tapfw`, `:taffw`, `:tacfw`, `:tapas`
- `network::String`         : Network
- `assignment::Symbol=:UE`  : Assignment type; one of `:UE`, `:SO`
- `tol::Float64=1e-5`       : Tolerance level for relative gap
- `maxiters::Int64=20`      : Maximum number of iterations
- `maxruntime::Int64=300`   : Maximum algorithm run time (seconds)
- `log::Symbol`             : Log iterations (one of `:off`, `:on`)
"""
assigntraffic(; method, network, assignment=:UE, tol=1e-5, maxiters=20, maxruntime=300, log=:off) = getfield(TA, method)(build(network, assignment), tol, maxiters, maxruntime, log)