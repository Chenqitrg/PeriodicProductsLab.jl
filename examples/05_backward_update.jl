# Run from PeriodicProductsLab: julia --project=. examples/05_backward_update.jl
using PeriodicProductsLab
using TensorKit
using Test

V = ℂ^2
factors = [TensorMap([1.0 Float64(i); 0.5 2.0], V, V) for i in 1:4]
cache = build_cache(length(factors), i -> factors[i])

@testset "Backward updates: 4 -> 3 -> 2 -> 1 -> 4" begin
    for site in 4:-1:2
        factors[site] = 2 * factors[site]
        advance!(cache, factors[site], SweepState{Backward}(site, 0))
        next_site = site - 1
        # Direction changes which half is refreshed, not multiplication order.
        order = vcat(collect(next_site+1:4), collect(1:next_site-1))
        expected = reduce(*, factors[order])
        @test environment(cache, next_site) ≈ expected
    end

    # Crossing 1 -> 4 needs the left cache, the mirror of the forward case.
    factors[1] = 2 * factors[1]
    invalidate!(cache, 1)
    @test_throws StaleCacheError environment(cache, 4)
    rebuild_left!(cache, i -> factors[i])
    @test environment(cache, 4) ≈ factors[1] * factors[2] * factors[3]
end

nothing
