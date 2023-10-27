# Traffic Assignment (TA)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/anmol1104/TA.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/anmol1104/TA.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/anmol1104/TA.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anmol1104/TA.jl)

```julia
assigntraffic(; method, network, assignment=:UE, tol=1e-5, maxiters=20, maxruntime=300, log=:off)
```

## Returns
a named tuple with keys `:metadata`, `:report`, and `:output`
- `metadata::String`  : Text defining the traffic assignment run 
- `report::DataFrame` : A log of total network flow, total network cost, and run time for every iteration
- `output::DataFrame` : Flow and cost for every arc from the final iteration

## Arguments
- `method::Symbol`          : One of `:tapfw`, `:taffw`, `:tacfw`, `:tapas`
- `network::String`         : Network
- `assignment::Symbol=:UE`  : Assignment type; one of `:UE`, `:SO`
- `tol::Float64=1e-5`       : Tolerance level for relative gap
- `maxiters::Int64=20`      : Maximum number of iterations
- `maxruntime::Int64=300`   : Maximum algorithm run time (seconds)
- `log::Symbol`             : Log iterations (one of `:off`, `:on`)

For futher details, refer to:
- Fukushima, M. (1984). A modified Frank-Wolfe algorithm for solving the traffic assignment problem. Transportation Research Part B: Methodological, 18(2), 169-177.
- Mitradjieva, M., & Lindberg, P. O. (2013). The stiff is moving—conjugate direction Frank-Wolfe Methods with applications to traffic assignment. Transportation Science, 47(2), 280-293.
- Bar-Gera, H. (2010). Traffic assignment by paired alternative segments. Transportation Research Part B: Methodological, 44(8-9), 1022-1046.
- Xie, J., & Xie, C. (2016). New insights and improvements of using paired alternative segments for traffic assignment. Transportation Research Part B: Methodological, 93, 406-424.