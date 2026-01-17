#!/usr/bin/env julia

"""
Setup verification script for CivilizationSim
Run this to check if all dependencies are properly installed
"""

println("="^60)
println("CivilizationSim Setup Verification")
println("="^60)

# Check Julia version
println("\n1. Checking Julia version...")
if VERSION >= v"1.9"
    println("   [OK] Julia $(VERSION) (>= 1.9 required)")
else
    println("   [FAIL] Julia $(VERSION) - Need 1.9 or higher")
    exit(1)
end

# Check core packages
println("\n2. Checking required packages...")
required_packages = [
    "Agents",
    "DataFrames", 
    "Distributions",
    "Graphs",
    "JSON3",
    "Plots",
    "Random",
    "Statistics",
    "StatsBase"
]

using Pkg
installed_packages = keys(Pkg.project().dependencies)

missing_packages = String[]
for pkg in required_packages
    if pkg in String.(installed_packages)
        println("   [OK] $pkg")
    else
        println("   [MISSING] $pkg")
        push!(missing_packages, pkg)
    end
end

if !isempty(missing_packages)
    println("\n   Installing missing packages...")
    Pkg.add(missing_packages)
end

# Check CUDA (optional)
println("\n3. Checking GPU support (optional)...")
try
    using CUDA
    if CUDA.functional()
        println("   [OK] CUDA available - GPU acceleration enabled")
        println("   Device: $(CUDA.name(CUDA.device()))")
        println("   Memory: $(CUDA.total_memory(CUDA.device()) ÷ 1024^3) GB")
    else
        println("   ! CUDA installed but no compatible GPU detected")
        println("   Simulation will run on CPU (this is fine)")
    end
catch e
    println("   ! CUDA not installed - GPU acceleration unavailable")
    println("   Simulation will run on CPU (this is fine)")
end

# Test basic functionality
println("\n4. Testing simulation components...")

try
    include("agents.jl")
    println("   [OK] agents.jl loaded")
catch e
    println("   [FAIL] Error loading agents.jl: $e")
    exit(1)
end

try
    include("Model.jl")
    println("   [OK] model.jl loaded")
catch e
    println("   [FAIL] Error loading model.jl: $e")
    exit(1)
end

try
    include("Simulate.jl")
    println("   [OK] simulate.jl loaded")
catch e
    println("   [FAIL] Error loading simulate.jl: $e")
    exit(1)
end

# Run minimal test
println("\n5. Running minimal simulation test...")
try
    model = initialize_civilization(n_agents = 10, grid_size = (10, 10))
    step!(model, 10)
    println("   [OK] Basic simulation works")
catch e
    println("   [FAIL] Simulation test failed: $e")
    exit(1)
end

println("\n" * "="^60)
println("Setup verification complete!")
println("="^60)
println("\nYou're ready to run simulations. Try:")
println("  julia --project=. simulate.jl")
println("\nOr in Julia REPL:")
println("  include(\"simulate.jl\")")
println("  quick_test()  # Fast test run")
println("  run_simulation()  # Full simulation")
println("="^60)