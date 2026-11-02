@testset "rebuild reuses valid prefixes and suffixes" begin
    # These counters measure actual factor reads and product operations.
    cases = (
        ((3,), [3, 4], [3, 2], 4),
        ((1,), [1, 2, 3, 4], Int[], 3),
        ((5,), Int[], [5, 4, 3, 2], 3),
        ((2, 4), [2, 3, 4], [4, 3, 2], 6),
    )
    for (changed, expected_left, expected_right, multiplications) in cases
        counter = CacheMultiplicationCounter(0)
        factors = [CountedCacheElement(i, counter) for i in 1:5]
        cache = build_cache(factors)
        for site in changed
            factors[site] = CountedCacheElement(10 + site, counter)
            invalidate!(cache, site)
        end
        left_reads, right_reads = Int[], Int[]
        counter.count = 0
        rebuild_left!(cache, i -> (push!(left_reads, i); factors[i]))
        rebuild_right!(cache, i -> (push!(right_reads, i); factors[i]))
        @test left_reads == expected_left
        @test right_reads == expected_right
        @test counter.count == multiplications
        for site in 1:5
            @test environment(cache, site).value ==
                  prod(factors[i].value for i in 1:5 if i != site)
        end

        # A fully valid cache requires no generation or multiplication.
        empty!(left_reads)
        empty!(right_reads)
        counter.count = 0
        rebuild_left!(cache, i -> (push!(left_reads, i); factors[i]))
        rebuild_right!(cache, i -> (push!(right_reads, i); factors[i]))
        rebuild!(cache, CountedProduct(factors))
        @test isempty(left_reads)
        @test isempty(right_reads)
        @test counter.count == 0
    end
end

@testset "rebuild resumes after a factor generation failure" begin
    for direction in (:left, :right)
        product = random_periodic_product(2, 5)
        cache = build_cache(product)
        product.sites[3] = 2 * product[3]
        invalidate!(cache, 3)
        reads = Int[]
        fail_site = direction == :left ? 4 : 2
        rebuild_direction! = direction == :left ? rebuild_left! : rebuild_right!
        @test_throws ErrorException rebuild_direction!(cache, i -> begin
            push!(reads, i)
            i == fail_site && error("factor generation failed")
            product[i]
        end)
        @test reads == [3, fail_site]
        if direction == :left
            @test left_cache_before(cache, 4) ≈ product[1] * product[2] * product[3]
            @test_throws StaleCacheError left_cache_before(cache, 5)
        else
            @test right_cache_after(cache, 2) ≈ product[3] * product[4] * product[5]
            @test_throws StaleCacheError right_cache_after(cache, 1)
        end
        empty!(reads)
        rebuild_direction!(cache, i -> (push!(reads, i); product[i]))
        @test reads == [fail_site]
        rebuild!(cache, product)
        @test all(environment(cache, i) ≈ naive_complement(product, i) for i in 1:5)
    end
end
