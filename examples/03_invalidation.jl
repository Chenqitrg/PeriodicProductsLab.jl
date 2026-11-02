# Run from PeriodicProductsLab: julia --project=. examples/03_invalidation.jl
using PeriodicProductsLab
using TensorKit
using Test

V = ℂ^2
factors = [TensorMap([1.0 Float64(i); 0.5 2.0], V, V) for i in 1:4]
cache = build_cache(factors)

# The caller owns the factors and must notify the cache about every change.
factors[2] = TensorMap([3.0 1.0; 1.0 2.0], V, V)
invalidate!(cache, 2)

@testset "Explicit invalidation and rebuild" begin
    # Site 2's own environment excludes factor 2, so it is still valid.
    @test environment(cache, 2) ≈ factors[3] * factors[4] * factors[1]
    @test_throws StaleCacheError environment(cache, 1)
    @test_throws StaleCacheError environment(cache, 3)

    # Reuse A on the left and C * D on the right; only repair stale products.
    rebuild!(cache, factors)
    @test environment(cache, 1) ≈ factors[2] * factors[3] * factors[4]
    @test environment(cache, 3) ≈ factors[4] * factors[1] * factors[2]
end

println("Factor 2 changed; valid products were reused, stale products repaired.")
nothing
