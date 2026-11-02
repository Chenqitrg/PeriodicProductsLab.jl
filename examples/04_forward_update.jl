# Run from PeriodicProductsLab: julia --project=. examples/04_forward_update.jl
using PeriodicProductsLab
using TensorKit
using Test

V = ℂ^2
factors = [TensorMap([1.0 Float64(i); 0.5 2.0], V, V) for i in 1:4]
cache = build_cache(length(factors), i -> factors[i])

@testset "Forward updates: 1 -> 2 -> 3 -> 4 -> 1" begin
    for site in 1:3
        factors[site] = 2 * factors[site]  # A simple stand-in for a local update.
        # Arguments: updated site, number of completed sweeps (zero so far).
        advance!(cache, factors[site], SweepState{Forward}(site, 0))
        next_site = site + 1
        # Independent reference, ordered immediately after next_site.
        order = vcat(collect(next_site+1:4), collect(1:next_site-1))
        expected = reduce(*, factors[order])
        @test environment(cache, next_site) ≈ expected
    end

    # Crossing 4 -> 1 needs an explicit rebuild of the right cache.
    # advance! deliberately does not perform this whole-period work for us.
    factors[4] = 2 * factors[4]
    invalidate!(cache, 4)
    @test_throws StaleCacheError environment(cache, 1)
    rebuild_right!(cache, i -> factors[i])
    @test environment(cache, 1) ≈ factors[2] * factors[3] * factors[4]
end

nothing
