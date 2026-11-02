# Review PeriodicProductsLab through examples

Start with `01_environment.jl`. This package handles ordered periodic products;
it does not require an MPS. TensorKit maps on a two-dimensional space keep the
examples small enough to check by hand.

Each file is independent and demonstrates one feature:

| File | Review question |
| --- | --- |
| [01_environment.jl](01_environment.jl) | Why does removing B from A, B, C, D give C * D * A? |
| [02_prefix_suffix.jl](02_prefix_suffix.jl) | What is cached on either side of a site, including empty halves? |
| [03_invalidation.jl](03_invalidation.jl) | Which queries become stale, and how does rebuilding reuse valid products? |
| [04_forward_update.jl](04_forward_update.jl) | How does one local update prepare the next site, including the periodic boundary? |
| [05_backward_update.jl](05_backward_update.jl) | How does the same mechanism work in the opposite direction? |

From the PeriodicProductsLab directory, run one example:

```sh
julia --project=. examples/01_environment.jl
```

Or, in a Julia REPL started with `julia --project=.` in this directory:

```julia
include("examples/01_environment.jl")
```

Run every example with:

```sh
julia --project=. examples/review_periodic_products.jl
```

The examples use fixed tensors, so no random generator is needed. Assertions
compare TensorKit objects directly; there is no conversion to Array. Each file
ends with `nothing` to avoid displaying the returned test-set object in the REPL.

All examples start with `build_cache(factors)` because their factors are already
in a vector. The alternative `build_cache(N, i -> ...)` obtains factors through
a function, while `build_cache(product)` accepts a custom
`AbstractPeriodicProduct`. These entry points have the same cache semantics;
cache updates do not mutate caller-owned factors.

After changing factors and reporting them with `invalidate!`, use
`rebuild!(cache, factors)` to repair both directions. Use
`rebuild_left!(cache, factors)` or `rebuild_right!(cache, factors)` when only
one direction is needed. All three also accept a custom product or a callback.

The central rule is `environment(cache, i) = right * left`: start just after
site i and continue around the ring, excluding i. Query indices must be in
`1:length(cache)`; they do not wrap automatically. The caller owns the factors
and must report changes with `invalidate!` or `advance!`. `SweepState` describes
one cache update; it does not run an optimization algorithm or move a cursor.

After these examples, read `src/cache.jl` and `src/advance.jl` to connect each
operation to its implementation.
