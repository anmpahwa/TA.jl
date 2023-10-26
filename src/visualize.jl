"""
    visualize(; methods, network, assignment=:UE, tol=1e-5, maxiters=20, maxruntime=300, log=:on)

Compare assignment methods.
"""
function visualize(; methods, network, assignment=:UE, tol=1e-5, maxiters=20, maxruntime=300, log=:on)
    fig = plot()
    for method in methods
        _, report, = assigntraffic(; method=method, network=network, assignment=assignment, tol=tol, maxiters=maxiters, maxruntime=maxruntime, log=log)
        y = report[!,:LOG₁₀RG]
        x = 0:length(y)-1
        plot!(x,y, label=String(method))
    end
    display(fig)
end