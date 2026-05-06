# Civilization Simulation: Post-Human Society Evolution

An agent-based model exploring how a society built from transmitted human knowledge evolves when stripped of biological imperatives like emotion, instinct, and mortality.

## Concept

This simulation models a society where AI entities receive Earth's accumulated knowledge but lack biological drives. Over multiple 100-year generations, the model tracks:

- **Communication Protocol Evolution**: do they abandon slow verbal communication for direct data transfer or ambient mesh?
- **Infrastructure Deprecation**: do libraries become obsolete when memory is unlimited?
- **Purpose Without Biology**: what drives behavior without fear, pleasure, or survival instinct?
- **Knowledge Transmission**: how does information flow change without the need for external storage?

## Project Structure

```
AiSocietY/
├── agents.jl          ← Agent definitions and behaviors
├── Model.jl           ← Civilization model and infrastructure
├── Simulate.jl        ← Main simulation runner
├── Config.jl          ← Scenario configurations
├── verify.jl          ← Setup verification
├── Project.toml       ← Julia dependencies
├── APPROACH.md        ← Design decisions and technical approach
└── results/           ← Output directory (created on run)
    ├── protocol_evolution.png
    ├── library_usage.png
    ├── knowledge_seeking.png
    └── summary.json
```

## Requirements

- Julia 1.9 or later
- 8GB RAM minimum (500 agents or fewer)
- GPU optional: CUDA-compatible GPU enables large-scale simulations (1000+ agents)

## Installation

```bash
# Install Julia from julialang.org, then:
julia --project=.
```

```julia
using Pkg
Pkg.instantiate()
```

## Quick Start

```julia
include("Simulate.jl")
quick_test()  # 1000 steps, ~10 seconds
```

## Full Simulation

```julia
include("Simulate.jl")

model, data = run_simulation(
    n_agents = 100,
    n_steps = 10000,
    generations = 1
)
```

## Scenarios

Four named configurations are available in `Config.jl`:

| Scenario | Description |
|---|---|
| `default_config()` | 100 agents, 100-year baseline |
| `rapid_evolution_config()` | High efficiency bias, fast protocol transitions |
| `conservative_config()` | More infrastructure, slow evolution |
| `post_scarcity_config()` | No energy constraints, isolates knowledge dynamics |

## Sample Output

```
GENERATION 1 ANALYSIS (Year 100)
Population: 95
Average Knowledge Items: 8.43

Communication Protocols:
  verbal:     67 (70.5%)
  direct:     28 (29.5%)
  telepathic:  0 (0.0%)

Infrastructure Usage:
  Library visits: 1247
```

## Research Questions

1. At what generation do libraries become obsolete?
2. Does telepathic communication always dominate, or does it depend on efficiency bias distribution?
3. What happens to knowledge-seeking behavior when energy constraints are removed?
4. Can emergent knowledge specialization develop across agents?

## License

GNU Affero General Public License v3.0 (AGPL v3)

For commercial licensing: fierier.heated9b@icloud.com
