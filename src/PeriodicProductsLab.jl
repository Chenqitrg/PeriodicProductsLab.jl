module PeriodicProductsLab

using LinearAlgebra: mul!
using TensorKit: domain, codomain, SpaceMismatch

export AbstractPeriodicProduct, PeriodicCache, FormalIdentity, UnitalElement
export SweepDirection, Forward, Backward, SweepState
export build_cache, environment, prefix_products, suffix_products
export left_cache_before, right_cache_after, range_product, edge_space, edge_identity
export compose_product, StaleCacheError
export invalidate!, advance!, rebuild_left!, rebuild_right!, rebuild!

include("periodicproduct.jl")
include("formalidentity.jl")
include("productscans.jl")
include("cache.jl")
include("show.jl")
include("generatedproducts.jl")
include("advance.jl")

end
