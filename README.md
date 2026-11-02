# PeriodicProductsLab

Ordered periodic products and directional caches, with formal identities and explicit stale-cache detection.

## Use

```julia
using PeriodicProductsLab, TensorKit
factors = [id(ℂ^2) for _ in 1:4]
cache = build_cache(factors)
complement = environment(cache, 2)
factors[2] = 2 * factors[2]
invalidate!(cache, 2)
rebuild!(cache, factors)
```

`build_cache(factors)` accepts an ordinary one-based vector. Use
`build_cache(N, i -> ...)` to generate factors on demand, or `build_cache(product)`
for a custom `AbstractPeriodicProduct` implementing `length` and integer indexing.
All three construct the same prefix/suffix cache and copy endpoint factors so
cache updates do not mutate the inputs. Factor changes still require explicit
notification with `invalidate!` or `advance!`.

Rebuilds accept the same input forms:

| Input | Build | Repair both directions |
| --- | --- | --- |
| Vector | `build_cache(factors)` | `rebuild!(cache, factors)` |
| Custom product | `build_cache(product)` | `rebuild!(cache, product)` |
| Callback | `build_cache(N, i -> ...)` | `rebuild!(cache, i -> ...)` |

Use `rebuild_left!` or `rebuild_right!` with any of these inputs to repair only
one direction. A rebuild already knows the period length from the cache.

Directional rebuilds reuse valid cached products and repair only the invalid
portion. Calling them again on a valid cache performs no multiplications; the
callback overload makes no factor requests either. Always report changed factors
first; rebuilding does not detect unreported changes. Completed steps remain
valid if a later step fails.

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
