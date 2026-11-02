# Run from PeriodicProductsLab: julia --project=. examples/01_environment.jl
using PeriodicProductsLab
using TensorKit
using Test

# Four noncommuting factors; all calculations remain TensorKit operations.
V = ℂ^2
A = TensorMap([1.0 1.0; 0.0 1.0], V, V)
B = TensorMap([2.0 0.0; 0.0 1.0], V, V)
C = TensorMap([1.0 0.0; 1.0 1.0], V, V)
D = TensorMap([1.0 2.0; 0.0 1.0], V, V)
factors = [A, B, C, D]

# Cache the ordered products before and after each site.
cache = build_cache(factors)

# Remove B and start immediately AFTER its site: C * D * A.
# Multiplication order matters: A * C * D is generally different.
E2 = environment(cache, 2)
println("Environment at site 2: C * D * A")
@show E2

@testset "Periodic complement order" begin
    @test E2 ≈ C * D * A
    @test !isapprox(E2, A * C * D)
    @test environment(cache, 1) ≈ B * C * D
    @test environment(cache, 4) ≈ A * B * C
end

# Suppress the returned Test.DefaultTestSet object when using include(...).
nothing
