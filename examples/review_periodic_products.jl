# Optional runner; every numbered example also runs independently.
for file in (
    "01_environment.jl",
    "02_prefix_suffix.jl",
    "03_invalidation.jl",
    "04_forward_update.jl",
    "05_backward_update.jl",
)
    println("\n", file)
    include(joinpath(@__DIR__, file))
end
nothing
