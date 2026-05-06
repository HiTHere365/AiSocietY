# Design Approach

## Origin

This started as a thought experiment during a conversation about AI and what a post-human society might actually look like: not robots, but AI entities that inherit all of recorded human knowledge without the biological drives that shaped it. No hunger, no fear, no mortality, no emotional attachment to tradition. What do they do with libraries when memory is unlimited? What happens to verbal language when direct data transfer is possible?

The interesting question is not what they would look like at a snapshot in time, but how they would evolve. That evolution is what this simulation models.

## Why Agent-Based Modeling

The behavior of a post-human society is not analytically tractable. You cannot write down an equation for "when do libraries become obsolete" because the answer depends on emergent interactions between hundreds of agents making local decisions. Agent-based modeling lets each entity act on its own state and neighborhood, and macro-level patterns emerge from the bottom up.

Each `Citizen` agent tracks its own energy, accumulated knowledge, communication protocol, and behavioral biases. Civilization-level metrics (protocol adoption rates, infrastructure usage, knowledge transfer volume) emerge from aggregating individual agent states over time rather than being specified directly.

## Markov Chain State Transitions

Agent behavior follows a priority-ordered decision function that maps the current state to a next action: seek energy when depleted, seek knowledge when curious, socialize when energy is sufficient, optimize behavior otherwise. This is a Markov process: the next action depends only on the agent's current state, not on its full history.

Communication protocol evolution is the most consequential Markov chain in the model. Each agent transitions through three states representing increasing communication efficiency:

```
verbal -> direct -> telepathic
```

- **verbal**: high-overhead language-based transfer, lossy, unidirectional
- **direct**: targeted data transfer, low overhead, reliable
- **telepathic**: fully integrated ambient communication, near-zero overhead

Transition probability is a function of the agent's `efficiency_bias` trait and accumulated knowledge. Agents with high efficiency bias and large knowledge sets evolve faster. The transition is one-directional by design: once an agent adopts direct transfer, there is no incentive to revert to verbal communication.

The key research question this enables: what is the stationary distribution of communication protocols across the population, and how sensitive is it to the initial distribution of `efficiency_bias` across agents?

## Monte Carlo Analysis

A single simulation run is one sample from a distribution of possible outcomes. The same initial conditions with a different random seed produce a different trajectory. To understand the model's behavior rigorously, the same scenario is run across many independent seeds and the distribution of outcomes is analyzed rather than any single run.

This answers questions a single run cannot: what is the probability that libraries become obsolete by generation 3? How much variance is there in telepathic adoption rates? Is the outcome deterministic or highly sensitive to initial conditions?

Monte Carlo also enables confidence intervals on key metrics, making it possible to distinguish genuine model behavior from sampling noise.

## Configuration and Scenarios

`Config.jl` externalizes all parameters: population size, infrastructure density, energy dynamics, curiosity and efficiency distributions, protocol evolution rates and thresholds. Four named scenarios are provided:

- **default**: baseline 100-agent, 100-year run
- **rapid_evolution**: higher efficiency bias, faster protocol transitions
- **conservative**: more infrastructure, higher evolution threshold, slower change
- **post_scarcity**: minimal energy constraints, isolates knowledge and protocol dynamics

This separation between configuration and simulation logic makes controlled experiments straightforward: change one parameter, hold everything else fixed, compare outcomes across Monte Carlo runs.

## Current Limitation: Fixed Protocol Ladder

The current model hard-codes a linear evolution path. Every agent moves along the same ladder in the same order. This is a useful simplification for a first model but misses the most interesting behavior: the available communication channels are a function of the physical substrate the entity inhabits and the medium available in that environment.

An entity with access to conductive mineral ground networks has a different protocol search space than one operating in low-gravity with atmospheric propagation. The protocol path is not particularly universal as much as it is more environment-dependent.

## Planned Extensions

- **Environment-parameterized protocol discovery**: replace the fixed protocol ladder with a search problem. Given world physics parameters (gravity, atmosphere, ground conductance, electromagnetic environment) and entity substrate, derive which channels are physically possible and let the population converge on them through efficiency selection. This maps directly to multi-agent communication research where agents learn signaling protocols rather than inheriting predefined ones.
- **Semantic knowledge representation**: replace string-set knowledge with embeddings, enabling knowledge similarity, specialization clustering, and semantic drift analysis across generations
- **Human knowledge corpus**: seed the initial knowledge base from a structured corpus rather than synthetic tokens, grounding the simulation in real information domains
- **Generational transmission**: agent spawning with knowledge inheritance, enabling cultural transmission analysis across lineages
- **World physics parameters**: expose environment as a first-class simulation variable, enabling cross-world comparison of protocol emergence
