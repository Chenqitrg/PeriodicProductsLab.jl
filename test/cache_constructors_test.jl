@testset "cache constructors — equivalent inputs and independent storage" begin
    builders = (
        vector = factors -> build_cache(factors),
        product = factors -> build_cache(MatrixPeriodicProduct(factors)),
        callback = factors -> build_cache(length(factors), i -> factors[i]),
    )

    for (name, build) in pairs(builders)
        @testset "$name" begin
            # Rectangular maps test composition at nonuniform interfaces.
            spaces = [ℂ^2, ℂ^3, ℂ^4, ℂ^2]
            factors = [
                TensorMap(ones(dim(spaces[i]), dim(spaces[mod1(i + 1, 4)])),
                    spaces[i], spaces[mod1(i + 1, 4)]) for i in 1:4
            ]
            cache = build(factors)
            for site in 1:4
                order = [mod1(site + offset, 4) for offset in 1:3]
                @test environment(cache, site) ≈ reduce(*, factors[order])
            end

            # Both endpoint refreshes must leave caller-owned tensors unchanged.
            original = copy.(factors)
            advance!(cache, 2 * factors[1], SweepState{Forward}(1, 0))
            @test all(factors[i] ≈ original[i] for i in 1:4)
            @test left_cache_before(cache, 2) ≈ 2 * original[1]
            cache = build(factors)
            advance!(cache, 3 * factors[4], SweepState{Backward}(4, 0))
            @test all(factors[i] ≈ original[i] for i in 1:4)
            @test right_cache_after(cache, 3) ≈ 3 * original[4]

            single = build([id(ℂ^2)])
            @test environment(single, 1) isa FormalIdentity
            @test_throws ArgumentError build(typeof(factors[1])[])
            @test_throws SpaceMismatch build([factors[1]])
        end
    end

    @testset "vector views" begin
        factors = [id(ℂ^2) for _ in 1:4]
        cache = build_cache(@view factors[2:3])
        @test length(cache) == 2
        @test environment(cache, 1) ≈ factors[3]
    end
end
