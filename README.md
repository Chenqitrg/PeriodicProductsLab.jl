# PeriodicProductsLab

Ordered periodic products and directional caches, with formal identities and explicit stale-cache detection.

## Use

```julia
using PeriodicProductsLab, TensorKit
factors = [id(ℂ^2) for _ in 1:4]
cache = build_cache(4, i -> factors[i])
complement = environment(cache, 2)
invalidate!(cache, 2)
rebuild_left!(cache, i -> factors[i])
rebuild_right!(cache, i -> factors[i])
```

## Review order

Start with the [feature-by-feature examples](examples/README.md), each runnable
independently. Then read the implementation:

1. `periodicproduct.jl`, `formalidentity.jl`: product and identity protocols.
2. `productscans.jl`, `cache.jl`: scans, queries, and validity.
3. `generatedproducts.jl`, `advance.jl`: construction and directional refresh.

All source files are in `src/`; focused regression tests live in `test/`.

## Dependencies and local tests

Only TensorKit and LinearAlgebra are runtime dependencies. Factors implement the domain/codomain and multiplication protocol; no MPS or algorithm configuration is required. SweepDirection and SweepState describe cache movement; complete sweep algorithms belong to MPSSplitLab.

From this repository:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
```

## Origin

Extracted from PMPSLab without changing numerical equations or configuration semantics.
Import each responsibility from its owning package; MPSSplitLab provides splitting algorithms. Version: `0.1.0`.

This research code builds on TensorKit.jl and MPSKit.jl; the numerical work also
draws on TNRKit.jl where applicable. Credit remains with those projects and their
authors and contributors. See the sibling MPSSplitLab README for the original attribution.
