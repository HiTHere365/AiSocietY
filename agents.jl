"""
Agent definitions for the civilization simulation.
Defines Citizen agents and their behaviors.
"""

using Agents
using Random
using Statistics

# Citizen agent definition
@agent struct Citizen(GridAgent{2})
    energy::Float64
    age::Int
    alive::Bool

    # Knowledge and learning
    knowledge::Set{String}
    curiosity::Float64
    library_visits::Int
    knowledge_shared::Int

    # Social behavior
    social_protocol::Symbol  # :verbal, :direct, :telepathic
    efficiency_bias::Float64

    # Tracking
    last_action::Symbol
end

# Create a new citizen with default values
function create_citizen(id::Int, pos::NTuple{2,Int})
    return Citizen(
        id,
        pos,
        100.0,              # energy
        0,                  # age
        true,               # alive
        Set{String}(),      # knowledge
        rand(),             # curiosity (0-1)
        0,                  # library_visits
        0,                  # knowledge_shared
        :verbal,            # social_protocol
        rand(),             # efficiency_bias (0-1)
        :idle               # last_action
    )
end

# Energy management
function manage_energy!(agent::Citizen, model)
    # Base energy cost per step
    agent.energy -= 0.5

    # Additional cost based on protocol complexity
    if agent.social_protocol == :telepathic
        agent.energy -= 0.2
    elseif agent.social_protocol == :direct
        agent.energy -= 0.1
    end

    # Natural regeneration
    agent.energy += 0.3

    # Clamp energy
    agent.energy = clamp(agent.energy, 0.0, 150.0)

    # Death check
    if agent.energy <= 0
        agent.alive = false
    end
end

# Decide what action to take
function decide_action(agent::Citizen, model)
    # Priority: survival > learning > socializing > optimization

    if agent.energy < 30
        return :seek_energy
    end

    # Roll based on curiosity and efficiency bias
    roll = rand()

    if roll < agent.curiosity * 0.5
        return :seek_knowledge
    elseif roll < 0.7
        return :socialize
    elseif roll < 0.7 + agent.efficiency_bias * 0.2
        return :optimize_behavior
    else
        return :idle
    end
end

# Acquire knowledge from a source
function acquire_knowledge!(agent::Citizen, source::Symbol, model)
    if source == :library
        # Find nearby library and get knowledge from it
        for lib in model.libraries
            if distance(agent.pos, lib.pos) < 5
                # Acquire random knowledge items
                available = collect(lib.knowledge_items)
                if !isempty(available)
                    new_item = rand(available)
                    push!(agent.knowledge, new_item)
                    agent.library_visits += 1
                end
                break
            end
        end
    end
end

# Share knowledge with another agent
function share_knowledge!(agent::Citizen, peer::Citizen, model)
    if !peer.alive || isempty(agent.knowledge)
        return
    end

    # Transfer efficiency based on protocol
    transfer_chance = if agent.social_protocol == :telepathic
        0.9
    elseif agent.social_protocol == :direct
        0.7
    else  # verbal
        0.4
    end

    if rand() < transfer_chance
        # Share a random piece of knowledge
        knowledge_item = rand(collect(agent.knowledge))
        push!(peer.knowledge, knowledge_item)
        agent.knowledge_shared += 1

        # Track by protocol
        model.knowledge_transfers[agent.social_protocol] += 1
    end
end

# Evolve communication protocol based on efficiency
function evolve_protocol!(agent::Citizen, model)
    if !model.allow_protocol_evolution
        return
    end

    # Chance to evolve based on efficiency bias and knowledge level
    evolution_chance = agent.efficiency_bias * 0.01 * (1 + length(agent.knowledge) * 0.1)

    if rand() < evolution_chance
        if agent.social_protocol == :verbal
            agent.social_protocol = :direct
        elseif agent.social_protocol == :direct
            agent.social_protocol = :telepathic
        end
    end
end

# Helper: calculate distance (also defined in model.jl, but needed here too)
function distance(pos1::NTuple{2,Int}, pos2::NTuple{2,Int})
    return sqrt((pos1[1] - pos2[1])^2 + (pos1[2] - pos2[2])^2)
end

export Citizen, create_citizen
export manage_energy!, decide_action, acquire_knowledge!
export share_knowledge!, evolve_protocol!
