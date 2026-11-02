using Test, PeriodicProductsLab
import TensorKit

struct Factor
    value::Int
end
TensorKit.domain(::Factor) = :scalar
TensorKit.codomain(::Factor) = :scalar
Base.:*(a::Factor, b::Factor) = Factor(a.value * b.value)
Base.copy(a::Factor) = a

@testset "product package works without MPS or execution" begin
    cache = build_cache(3, Factor)
    @test environment(cache, 2).value == 3
    invalidate!(cache, 2)
    @test_throws StaleCacheError environment(cache, 1)
    for name in (:PeriodicMPS, :AbstractAlgorithmConfig, :SplitRun, :ExecutionLab)
        @test !isdefined(PeriodicProductsLab, name)
    end
end
