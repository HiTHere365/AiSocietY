# Civilization Simulation: Post-Human Society Evolution

An agent-based model exploring how a society built from transmitted human knowledge evolves when stripped of biological imperatives like emotion, instinct, and mortality.

## Concept

This simulation models a society where AI-created entities receive Earth's knowledge but lack biological drives. Over multiple 100-year generations, we observe:

- **Communication Protocol Evolution**: Do they abandon slow verbal communication for direct data transfer?
- **Infrastructure Deprecation**: Do libraries become obsolete when memory is unlimited?
- **Purpose Without Biology**: What drives behavior without fear, pleasure, or survival instinct?
- **Knowledge Transmission**: How does information flow change without the need for external storage?

## Hardware Requirements

- **Recommended**: 
  - GPU: NVIDIA RTX 5090 (24GB VRAM) - for GPU-accelerated large-scale simulations
  - RAM: 64GB - for running thousands of agents
  - Storage: 2TB - for simulation data output

- **Minimum**: 
  - Any system that can run Julia 1.9+
  - 8GB RAM for small simulations (<500 agents)

## Installation

### 1. Install Julia

Download Julia 1.9 or later from [julialang.org](https://julialang.org/downloads/)

```bash
# Verify installation
julia --version
```

### 2. Set Up Project

```bash
# Clone or create project directory
cd /path/to/CivilizationSim

# Start Julia in project directory
julia --project=.

# In Julia REPL, install dependencies:
julia> using Pkg
julia> Pkg.instantiate()  # Install all dependencies from Project.toml
```

### 3. Install CUDA Support (for GPU acceleration)

```julia
# In Julia REPL
using Pkg
Pkg.add("CUDA")

# Test CUDA
using CUDA
CUDA.functional()  # Should return true if GPU is detected
```

## Project Structure

```
CivilizationSim/
├── Project.toml          # Dependencies
├── agents.jl             # Agent definitions and behaviors
├── model.jl              # Civilization model and infrastructure
├── simulate.jl           # Main simulation runner
├── README.md             # This file
└── results/              # Output directory (created on run)
    ├── protocol_evolution.png
    ├── library_usage.png
    ├── knowledge_seeking.png
    └── summary.json
```

## Quick Start

### Test Run (1000 steps, ~10 seconds)

```julia
# Start Julia
julia --project=.

# Run quick test
include("simulate.jl")
quick_test()
```

### Full Simulation (100 years)

```julia
include("simulate.jl")

# Run 100-year simulation with 100 agents
model, data = run_simulation(
    n_agents = 100,
    n_steps = 10000,    # 100 steps = 1 year
    generations = 1
)
```

### Multi-Generation Simulation (200+ years)

```julia
# Run for 5 generations (500 years)
model, data = run_simulation(
    n_agents = 200,
    n_steps = 10000,
    generations = 5
)
```

## Understanding the Output

### Console Output

Every 100 years (10,000 steps), you'll see analysis like:

```
============================================================
GENERATION 1 ANALYSIS (Year 100)
============================================================
Population: 95
Average Knowledge Items: 8.43
Average Age: 5432.1

Communication Protocols:
  verbal: 67 (70.5%)
  direct: 28 (29.5%)
  telepathic: 0 (0.0%)

Infrastructure Usage:
  Library visits: 1247

Knowledge Transfers by Protocol:
  verbal: 834
  direct: 413
  telepathic: 0
============================================================
```

### Generated Files

- `protocol_evolution.png`: Shows adoption of verbal → direct → telepathic communication
- `library_usage.png`: Tracks if libraries become obsolete
- `knowledge_seeking.png`: Measures information-gathering behavior over time
- `summary.json`: Statistical summary of the simulation

## Extending the Simulation

### Add New Agent Behaviors

Edit `agents.jl`:

```julia
function decide_action(agent::Citizen, model)
    # Add your new decision logic here
    if some_condition
        return :your_new_action
    end
    # ... existing logic
end
```

### Add New Infrastructure

Edit `model.jl`:

```julia
struct YourNewInfrastructure
    pos::NTuple{2,Int}
    your_properties::Int
end
```

### Modify Evolution Rules

Change protocol evolution speed, knowledge acquisition rates, or infrastructure deprecation thresholds in `agents.jl` and `model.jl`.

## Key Parameters to Experiment With

In `agents.jl`:

- `curiosity`: How much agents seek knowledge (0.0-1.0)
- `efficiency_bias`: Tendency to optimize behaviors (0.0-1.0)
- Energy costs for different actions

In `model.jl`:

- `n_libraries`, `n_hospitals`: Infrastructure density
- `allow_protocol_evolution`: Enable/disable communication evolution
- Protocol evolution thresholds

## Advanced: GPU Acceleration

For simulations with 1000+ agents, you can enable GPU acceleration:

```julia
# TODO: Add CUDA kernel implementations for:
# - Parallel agent stepping
# - Distance calculations
# - Knowledge graph operations

using CUDA

# Example GPU kernel (to be implemented)
function gpu_agent_step!(agents_gpu, model_params)
    # CUDA kernel code here
end
```

## Research Questions to Explore

1. **At what generation do libraries become obsolete?**
   - Run multiple simulations with different parameters
   - Track `library_usage.png` across generations

2. **Does telepathic communication always win?**
   - Adjust `efficiency_bias` distributions
   - Observe protocol adoption rates

3. **What happens without energy constraints?**
   - Remove or increase energy regeneration
   - See if knowledge seeking increases

4. **Can you create emergent "specialization"?**
   - Add agent types with different knowledge domains
   - Measure if knowledge clustering occurs

## Troubleshooting

### Julia Package Issues

```julia
# Reset package environment
using Pkg
Pkg.resolve()
Pkg.update()
```

### GPU Not Detected

```julia
using CUDA
CUDA.versioninfo()  # Check CUDA installation
```

### Out of Memory

Reduce agent count or simulation length:

```julia
run_simulation(n_agents = 50, n_steps = 5000, generations = 1)
```

## Next Steps

1. **Add LLM Integration**: Give agents reasoning capabilities via local Llama models
2. **Multi-dimensional Knowledge**: Replace simple string sets with semantic embeddings
3. **Reproductive Mechanics**: Add agent spawning to study cultural transmission
4. **Resource Competition**: Add scarce resources to create evolutionary pressure

## Contributing

This is a starter framework - expand it however you want! Some ideas:

- Add visualization of agent movement
- Implement actual "hospitals" that affect agent longevity
- Create knowledge networks (graph-based knowledge representation)
- Add inter-agent cooperation or conflict mechanics

## Credits

Built as a thought experiment in modeling post-biological societies.

## License

MIT License - Use however you want!