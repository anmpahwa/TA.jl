using TA
using Revise
using Test

# Traffic Assignment by Pure Frank Wolfe
@testset "TAPFW" begin
    assignment = assigntraffic(; method=:tapfw, network="Anaheim", assignment=:UE, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ

    assignment = assigntraffic(; method=:tapfw, network="Anaheim", assignment=:SO, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ
end

# Traffic Assignment by Fukushima Frank Wolfe
@testset "TAFFW" begin
    assignment = assigntraffic(; method=:taffw, network="Anaheim", assignment=:UE, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ

    assignment = assigntraffic(; method=:taffw, network="Anaheim", assignment=:SO, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ
end

# Traffic Assignment by Conjugate Frank Wolfe
@testset "TACFW" begin
    assignment = assigntraffic(; method=:tacfw, network="Anaheim", assignment=:UE, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ

    assignment = assigntraffic(; method=:tacfw, network="Anaheim", assignment=:SO, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ
end

# Traffic Assignment by Paired Alternative Segments
@testset "TAPAS" begin
    assignment = assigntraffic(; method=:tapas, network="Anaheim", assignment=:UE, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ

    assignment = assigntraffic(; method=:tapas, network="Anaheim", assignment=:SO, tol=1e-50, maxiters=5, maxruntime=300, log=:off)
    report = assignment[:report]
    s, e = 1, size(report,1)
    rgₛ = report[s, :LOG₁₀RG]
    rgₑ = report[e, :LOG₁₀RG]
    @test rgₑ < rgₛ
end
