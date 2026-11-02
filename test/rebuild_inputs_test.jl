@testset "rebuild inputs share incremental behavior" begin
    sources = (
        vector = factors -> factors,
        view = factors -> view(factors, :),
        product = factors -> CountedProduct(factors),
        callback = factors -> (i -> factors[i]),
    )
    for (name, source) in pairs(sources)
        @testset "$name" begin
            counter = CacheMultiplicationCounter(0)
            factors = [CountedCacheElement(i, counter) for i in 1:5]
            for mode in (:both, :directional)
                cache = build_cache(factors)
                factors[3] = CountedCacheElement(factors[3].value + 1, counter)
                invalidate!(cache, 3)
                counter.count = 0
                if mode == :both
                    @test rebuild!(cache, source(factors)) === cache
                else
                    @test rebuild_left!(cache, source(factors)) === cache
                    @test_throws StaleCacheError right_cache_after(cache, 1)
                    @test rebuild_right!(cache, source(factors)) === cache
                end
                @test counter.count == 4
                for site in 1:5
                    @test environment(cache, site).value ==
                          prod(factors[i].value for i in 1:5 if i != site)
                end
                counter.count = 0
                rebuild!(cache, source(factors))
                @test counter.count == 0
            end

            single = [CountedCacheElement(2, counter)]
            cache = build_cache(single)
            invalidate!(cache, 1)
            rebuild!(cache, source(single))
            @test environment(cache, 1) isa FormalIdentity
        end
    end
end

@testset "vector rebuild validates before modifying the cache" begin
    factors = [id(ℂ^2) for _ in 1:4]
    for rebuild in (rebuild!, rebuild_left!, rebuild_right!)
        cache = build_cache(factors)
        invalidate!(cache, 2)
        @test_throws DimensionMismatch rebuild(cache, factors[1:3])
        @test_throws SpaceMismatch rebuild(cache, [id(ℂ^3) for _ in 1:4])
        open_factors = copy(factors)
        open_factors[end] = TensorMap(ones(2, 3), ℂ^2, ℂ^3)
        @test_throws SpaceMismatch rebuild(cache, open_factors)
        @test_throws StaleCacheError environment(cache, 1)
        @test_throws StaleCacheError environment(cache, 3)
        @test environment(cache, 2) ≈ id(ℂ^2)
    end
end
