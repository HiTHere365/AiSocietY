# Monte Carlo Simulation & Markov Chains Integration Guide

## YES! This Framework is Perfect for Both

Your simulation is already using Monte Carlo methods implicitly, and Markov chains are a natural fit for modeling agent state transitions. Here's how to implement and extend them.

---

## Part 1: Monte Carlo Simulation (Already Happening!)

### What You're Already Doing

Monte Carlo simulation means running the same experiment many times with random parameters to understand the distribution of outcomes. Your simulation already has randomness:

```julia
# In agents.jl
curiosity = rand(Uniform(0.3, 0.9))  # Random agent traits
efficiency_bias = rand(Uniform(0.1, 0.8))

# In model.jl  
if rand() < efficiency
    # Probabilistic knowledge sharing
end
```

### Making it More Monte Carlo

**Goal**: Run the simulation 100 times and analyze the distribution of outcomes.

#### Implementation:

```julia
# Add this to a new file: monte_carlo.jl

using Statistics
using DataFrames
using Plots

"""
Run Monte Carlo simulation: same scenario, N different random seeds
"""
function run_monte_carlo(;
    n_runs::Int = 100,
    scenario::String = "default",
    output_dir::String = "monte_carlo_results"
)
    
    println("="^60)
    println("MONTE CARLO SIMULATION")
    println("Running $n_runs independent simulations...")
    println("="^60)
    
    # Storage for results across all runs
    results = DataFrame(
        run = Int[],
        final_population = Int[],
        telepathic_pct = Float64[],
        library_visits = Int[],
        generations_to_50pct_telepathic = Union{Int, Nothing}[],
        library_obsolescence_generation = Union{Int, Nothing}[]
    )
    
    for run in 1:n_runs
        println("\nRun $run/$n_runs...")
        
        # Each run gets different random seed
        model = initialize_civilization(
            n_agents = 100,
            seed = run  # Different seed each time
        )
        
        # Track when key events happen
        telepathic_50pct_gen = nothing
        library_obsolete_gen = nothing
        
        # Run simulation
        for gen in 1:5  # 5 generations = 500 years
            step!(model, 10000)  # 100 years
            
            # Check milestones
            alive = collect(allagents(model))
            alive = filter(a -> a.alive, alive)
            
            if !isempty(alive)
                telepathic_pct = count(a -> a.social_protocol == :telepathic, alive) / length(alive)
                
                # Track when 50% adopt telepathy
                if isnothing(telepathic_50pct_gen) && telepathic_pct >= 0.5
                    telepathic_50pct_gen = gen
                end
                
                # Track when libraries become obsolete (< 5 visits per generation)
                recent_lib_visits = sum(model.infrastructure_usage[:library][max(1, end-10):end])
                if isnothing(library_obsolete_gen) && recent_lib_visits < 50
                    library_obsolete_gen = gen
                end
            end
        end
        
        # Collect final state
        alive_final = filter(a -> a.alive, collect(allagents(model)))
        
        push!(results, (
            run,
            length(alive_final),
            isempty(alive_final) ? 0.0 : count(a -> a.social_protocol == :telepathic, alive_final) / length(alive_final),
            sum(model.infrastructure_usage[:library]),
            telepathic_50pct_gen,
            library_obsolete_gen
        ))
    end
    
    # Analyze results
    analyze_monte_carlo(results, output_dir)
    
    return results
end

function analyze_monte_carlo(results::DataFrame, output_dir::String)
    mkpath(output_dir)
    
    println("\n" * "="^60)
    println("MONTE CARLO ANALYSIS")
    println("="^60)
    
    # Summary statistics
    println("\nFinal Population:")
    println("  Mean: $(round(mean(results.final_population), digits=2))")
    println("  Std:  $(round(std(results.final_population), digits=2))")
    println("  Range: [$(minimum(results.final_population)), $(maximum(results.final_population))]")
    
    println("\nTelepathic Adoption (%):")
    println("  Mean: $(round(mean(results.telepathic_pct) * 100, digits=1))%")
    println("  Std:  $(round(std(results.telepathic_pct) * 100, digits=1))%")
    
    println("\nLibrary Visits:")
    println("  Mean: $(round(mean(results.library_visits), digits=0))")
    println("  Std:  $(round(std(results.library_visits), digits=0))")
    
    # Time to milestones
    telepathic_times = filter(!isnothing, results.generations_to_50pct_telepathic)
    if !isempty(telepathic_times)
        println("\nGenerations to 50% Telepathic Adoption:")
        println("  Mean: $(round(mean(telepathic_times), digits=2))")
        println("  Range: [$(minimum(telepathic_times)), $(maximum(telepathic_times))]")
    end
    
    obsolete_times = filter(!isnothing, results.library_obsolescence_generation)
    if !isempty(obsolete_times)
        println("\nGenerations to Library Obsolescence:")
        println("  Mean: $(round(mean(obsolete_times), digits=2))")
        println("  Range: [$(minimum(obsolete_times)), $(maximum(obsolete_times))]")
    end
    
    # Visualizations
    
    # 1. Distribution of final telepathic adoption
    p1 = histogram(
        results.telepathic_pct * 100,
        bins = 20,
        xlabel = "Telepathic Adoption (%)",
        ylabel = "Frequency",
        title = "Distribution of Telepathic Adoption (N=$(nrow(results)))",
        legend = false,
        color = :blue,
        alpha = 0.7
    )
    vline!([mean(results.telepathic_pct) * 100], color = :red, linewidth = 2, label = "Mean")
    savefig(p1, joinpath(output_dir, "telepathic_distribution.png"))
    
    # 2. Library visits distribution
    p2 = histogram(
        results.library_visits,
        bins = 20,
        xlabel = "Total Library Visits",
        ylabel = "Frequency", 
        title = "Distribution of Library Usage",
        legend = false,
        color = :green,
        alpha = 0.7
    )
    savefig(p2, joinpath(output_dir, "library_distribution.png"))
    
    # 3. Time to 50% telepathic (if available)
    if !isempty(telepathic_times)
        p3 = histogram(
            telepathic_times,
            bins = 10,
            xlabel = "Generations",
            ylabel = "Frequency",
            title = "Time to 50% Telepathic Adoption",
            legend = false,
            color = :purple,
            alpha = 0.7
        )
        savefig(p3, joinpath(output_dir, "time_to_telepathic.png"))
    end
    
    # 4. Scatter: library usage vs telepathic adoption
    p4 = scatter(
        results.telepathic_pct * 100,
        results.library_visits,
        xlabel = "Telepathic Adoption (%)",
        ylabel = "Total Library Visits",
        title = "Relationship: Communication Protocol vs Library Usage",
        legend = false,
        markersize = 5,
        alpha = 0.6,
        color = :orange
    )
    savefig(p4, joinpath(output_dir, "protocol_vs_library.png"))
    
    # Save results
    using CSV
    CSV.write(joinpath(output_dir, "monte_carlo_results.csv"), results)
    
    println("\n✓ Analysis complete! Results saved to $output_dir")
end

# Confidence intervals
function calculate_ci(data::Vector{Float64}, confidence::Float64 = 0.95)
    n = length(data)
    m = mean(data)
    s = std(data)
    
    # t-distribution critical value (approximation for large n)
    z = 1.96  # For 95% CI
    
    margin = z * (s / sqrt(n))
    
    return (m - margin, m + margin)
end

export run_monte_carlo, analyze_monte_carlo
```

### Usage:

```julia
include("monte_carlo.jl")

# Run 100 simulations
results = run_monte_carlo(n_runs = 100)

# Answers questions like:
# - What's the PROBABILITY libraries become obsolete by year 300?
# - How much VARIANCE is there in telepathic adoption?
# - Is the outcome deterministic or highly variable?
```

---

## Part 2: Markov Chains (Agent State Transitions)

### What are Markov Chains?

A Markov chain models how agents transition between discrete states based on probabilities. In your simulation, agent states could be:

- **Communication protocol**: verbal → direct → telepathic
- **Knowledge level**: novice → intermediate → expert
- **Activity state**: idle → seeking → sharing → optimizing

### Current Implicit Markov Chain

You already have one! Communication protocol evolution:

```
verbal --[p1]--> direct --[p2]--> telepathic
  ↑                                     |
  └─────────[p3]────────────────────────┘
```

### Explicit Markov Chain Implementation

#### Step 1: Define State Space

```julia
# Add to agents.jl

@enum AgentState begin
    IDLE
    SEEKING_ENERGY
    SEEKING_KNOWLEDGE
    SOCIALIZING
    OPTIMIZING
end

# Add to Citizen struct
state::AgentState
state_history::Vector{AgentState}  # Track state transitions
```

#### Step 2: Define Transition Matrix

```julia
# Add this to a new file: markov.jl

using LinearAlgebra
using Plots

"""
Markov chain transition matrix for agent states
Rows = current state, Columns = next state
Each row sums to 1.0
"""
function get_transition_matrix(agent::Citizen, model)
    # Base transition probabilities
    if agent.energy < 30
        # Low energy: very likely to seek energy
        return [
            0.1  0.8  0.05 0.05 0.0;   # IDLE → ?
            0.0  0.9  0.05 0.05 0.0;   # SEEKING_ENERGY → ?
            0.1  0.7  0.1  0.1  0.0;   # SEEKING_KNOWLEDGE → ?
            0.1  0.7  0.1  0.1  0.0;   # SOCIALIZING → ?
            0.1  0.7  0.1  0.1  0.0    # OPTIMIZING → ?
        ]
    elseif length(agent.knowledge) < 10
        # Low knowledge: prefer learning
        return [
            0.2  0.1  0.5  0.1  0.1;   # IDLE → ?
            0.3  0.1  0.4  0.1  0.1;   # etc.
            0.1  0.1  0.5  0.2  0.1;
            0.2  0.1  0.4  0.2  0.1;
            0.2  0.1  0.5  0.1  0.1
        ]
    else
        # Balanced state
        return [
            0.3  0.1  0.2  0.2  0.2;
            0.4  0.2  0.15 0.15 0.1;
            0.3  0.1  0.3  0.2  0.1;
            0.3  0.1  0.2  0.3  0.1;
            0.3  0.1  0.2  0.2  0.2
        ]
    end
end

"""
Decide next state using Markov chain
"""
function markov_next_state(agent::Citizen, model)
    # Get current state index
    current_idx = Int(agent.state) + 1  # Julia is 1-indexed
    
    # Get transition probabilities
    P = get_transition_matrix(agent, model)
    transition_probs = P[current_idx, :]
    
    # Sample next state
    next_idx = sample_categorical(transition_probs)
    next_state = AgentState(next_idx - 1)
    
    # Record transition
    push!(agent.state_history, next_state)
    
    return next_state
end

function sample_categorical(probs::Vector{Float64})
    r = rand()
    cumsum_probs = cumsum(probs)
    return findfirst(x -> x >= r, cumsum_probs)
end

"""
Analyze state transition patterns across all agents
"""
function analyze_markov_transitions(model)
    all_transitions = zeros(5, 5)  # 5x5 matrix for 5 states
    
    for agent in allagents(model)
        if !agent.alive || length(agent.state_history) < 2
            continue
        end
        
        # Count transitions
        for i in 1:(length(agent.state_history) - 1)
            from_state = Int(agent.state_history[i]) + 1
            to_state = Int(agent.state_history[i + 1]) + 1
            all_transitions[from_state, to_state] += 1
        end
    end
    
    # Normalize to probabilities
    for i in 1:5
        row_sum = sum(all_transitions[i, :])
        if row_sum > 0
            all_transitions[i, :] ./= row_sum
        end
    end
    
    return all_transitions
end

"""
Calculate stationary distribution (long-run state probabilities)
"""
function stationary_distribution(P::Matrix{Float64})
    # Find eigenvector with eigenvalue 1
    evals, evecs = eigen(P')
    
    # Find index of eigenvalue closest to 1
    idx = argmin(abs.(evals .- 1.0))
    
    # Get corresponding eigenvector
    stationary = real(evecs[:, idx])
    stationary ./= sum(stationary)  # Normalize
    
    return stationary
end

"""
Visualize Markov chain
"""
function plot_markov_chain(P::Matrix{Float64}, output_file::String)
    state_names = ["Idle", "Energy", "Knowledge", "Social", "Optimize"]
    
    # Heatmap of transition matrix
    p = heatmap(
        state_names, state_names,
        P,
        xlabel = "To State",
        ylabel = "From State",
        title = "Agent State Transition Probabilities",
        color = :viridis,
        clims = (0, 1)
    )
    
    # Annotate with probabilities
    for i in 1:5, j in 1:5
        if P[i, j] > 0.05
            annotate!(j, i, text(round(P[i, j], digits=2), 8, :white))
        end
    end
    
    savefig(p, output_file)
end

export markov_next_state, analyze_markov_transitions
export stationary_distribution, plot_markov_chain
```

### Usage Example:

```julia
include("markov.jl")

# Run simulation
model = initialize_civilization()
step!(model, 10000)

# Analyze observed transitions
P_observed = analyze_markov_transitions(model)
plot_markov_chain(P_observed, "observed_transitions.png")

# Calculate long-run state distribution
stationary = stationary_distribution(P_observed)
println("Long-run state probabilities:")
for (i, prob) in enumerate(stationary)
    println("  $(AgentState(i-1)): $(round(prob*100, digits=1))%")
end
```

---

## Part 3: Advanced Applications

### 1. Multi-Level Markov Chain

Model civilization-level transitions:

```julia
# Civilization states
@enum CivilizationState begin
    PRIMITIVE       # Verbal, libraries heavily used
    TRANSITIONAL    # Mix of protocols
    ADVANCED        # Direct transfer, libraries declining
    POST_BIOLOGICAL # Telepathic, no infrastructure
end

# Transition matrix for civilization
function civilization_transition(model)
    # Based on aggregate agent states
    telepathic_ratio = count_telepathic(model) / count_alive(model)
    library_usage = recent_library_usage(model)
    
    if telepathic_ratio < 0.1 && library_usage > 500
        return PRIMITIVE
    elseif telepathic_ratio < 0.5
        return TRANSITIONAL
    elseif telepathic_ratio < 0.9
        return ADVANCED
    else
        return POST_BIOLOGICAL
    end
end
```

### 2. Monte Carlo + Markov: Ensemble Analysis

```julia
# Run 1000 simulations, track Markov chain evolution
function ensemble_markov_analysis(n_runs = 1000)
    transition_matrices = []
    
    for run in 1:n_runs
        model = initialize_civilization(seed = run)
        step!(model, 50000)  # 500 years
        
        P = analyze_markov_transitions(model)
        push!(transition_matrices, P)
    end
    
    # Average transition matrix across all runs
    P_mean = mean(transition_matrices)
    
    # Variance in transition probabilities
    P_var = var(transition_matrices)
    
    return P_mean, P_var
end
```

### 3. Absorbing States

Model extinction as absorbing state:

```julia
# Add EXTINCT state
@enum AgentState begin
    IDLE
    SEEKING_ENERGY
    SEEKING_KNOWLEDGE
    SOCIALIZING
    OPTIMIZING
    EXTINCT  # Absorbing state
end

# Once in EXTINCT, can't leave
# P[EXTINCT, EXTINCT] = 1.0
# P[EXTINCT, *] = 0.0 for all other states
```

---

## Learning Path

### Week 1: Understand What's Already There
```julia
# Just run the basic simulation
include("simulate.jl")
quick_test()
```

### Week 2: Add Monte Carlo
```julia
# Run same scenario 10 times, see variance
include("monte_carlo.jl")
results = run_monte_carlo(n_runs = 10)
```

### Week 3: Implement Basic Markov Chain
```julia
# Add state tracking to agents
# Calculate observed transition matrix
# Visualize it
```

### Week 4: Combine Both
```julia
# Monte Carlo: 100 runs
# Each run: analyze Markov transitions
# Result: Distribution of transition matrices
```

---

## Why This is Perfect for Learning

1. **Concrete Application**: Not abstract examples, real questions about society
2. **Immediate Feedback**: Run it, see results, understand behavior
3. **Scales Nicely**: Start simple, add complexity gradually
4. **Publishable**: "Monte Carlo Analysis of Post-Biological Society Evolution"

---

## Resources to Study

### Monte Carlo
- **Book**: "Monte Carlo Methods" by Kroese et al.
- **Key Concepts**: 
  - Variance reduction
  - Confidence intervals
  - Sample size determination

### Markov Chains
- **Book**: "Introduction to Probability Models" by Ross
- **Julia Package**: `MarkovChains.jl`
- **Key Concepts**:
  - Stationary distribution
  - Absorbing states
  - Ergodicity

### Your Advantage
You're not learning from textbook examples of coin flips. You're learning by modeling **your actual research question**. That's way more effective.

---

## Quick Reference Commands

```julia
# Monte Carlo
include("monte_carlo.jl")
results = run_monte_carlo(n_runs = 100)

# Markov Analysis  
include("markov.jl")
P = analyze_markov_transitions(model)
stationary = stationary_distribution(P)
plot_markov_chain(P, "transitions.png")

# Combined
for run in 1:100
    model = initialize_civilization(seed = run)
    step!(model, 10000)
    P = analyze_markov_transitions(model)
    # Analyze P...
end
```

---

## Bottom Line

**Yes, absolutely doable.** Your simulation is actually a perfect testbed for both techniques. Monte Carlo lets you understand the variance in outcomes, Markov chains let you formalize the agent dynamics.

You're not just learning these methods abstractly - you're using them to answer: **"What's the probability that libraries become obsolete by generation 3?"** and **"What's the long-run equilibrium distribution of agent behaviors?"**

That's real research. Start simple, add complexity as you learn. Your hardware can handle it, and Tabby + Claude Code will help with syntax.

This is exactly how you learn mod-sim properly - by doing it on a problem you actually care about. 🚀