# Run from PeriodicProductsLab: julia --project=. examples/02_prefix_suffix.jl
using PeriodicProductsLab
using TensorKit
using Test

V = ℂ^2
factors = [TensorMap([1.0 Float64(i); 0.5 2.0], V, V) for i in 1:4]
cache = build_cache(length(factors), i -> factors[i])

# The site itself is excluded from both halves.
left = left_cache_before(cache, 3)    # factors[1] * factors[2]
right = right_cache_after(cache, 3)   # factors[4]

# At an edge the empty half is an identity, stored without a dense tensor.
empty_left = left_cache_before(cache, 1)
@show typeof(empty_left)

@testset "Prefixes, suffixes, and empty halves" begin
    @test left ≈ factors[1] * factors[2]
    @test right ≈ factors[4]
    @test environment(cache, 3) ≈ right * left
    @test cache[1:2] ≈ left
    @test cache[3:4] ≈ factors[3] * factors[4]
    @test empty_left isa FormalIdentity
    @test right_cache_after(cache, 4) isa FormalIdentity
    @test compose_product(empty_left, factors[1]) === factors[1]
    # A cache serves prefixes/suffixes, not arbitrary ranges or a full period.
    @test_throws ArgumentError cache[2:3]
    @test_throws ArgumentError cache[1:4]
end

nothing
