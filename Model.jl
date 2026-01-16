"""
Civilization model with infrastructure and societal structures.
Tracks how infrastructure usage evolves over time.
"""

using Agents
using Random
using Graphs

# Infrastructure types
struct Library
    pos::NTuple{2,Int}
    knowledge_items::Set{String}
    visits::Int
end

struct Hospital
    pos::NTuple{2,Int}
    treatments::Int
end

struct CommunicationHub
    pos::NTuple{2,Int}
    protocol_type::Symbol
    usage::Int
end

# Model properties
mutable struct CivilizationProperties
    # Infrastructure
    libraries::Vector{Library}
    hospitals::Vector{Hospital}
    comm_hubs::Vector{CommunicationHub}
    
    # Tracking metrics
    step::Int
    generation::Int  # Which 100-year generation we're in
    knowledge_transfers::Dict{Symbol, Int}
    infrastructure_usage::Dict{Symbol, Vector{Int}}
    
    # Evolution parameters
    allow_protocol_evolution::Bool
    allow_infrastructure_deprecation::Bool
end

# Initialize the civilization model
function initialize_civilization(;
    n_agents::Int = 100,
    grid_size::Tuple{Int,Int} = (50, 50),
    n_libraries::Int = 5,
    n_hospitals::Int = 3,
    seed::Int = 42
)
    
    # Create space
    space = GridSpaceSingle(grid_size; periodic = false)
    
    # Create RNG
    rng = MersenneTwister(seed)
    
    # Initialize infrastructure
    libraries = [
        Library(
            (rand(rng, 1:grid_size[1]), rand(rng, 1:grid_size[2])),
            Set(["knowledge_$i" for i in 1:50]),
            0
        ) for _ in 1:n_libraries
    ]
    
    hospitals = [
        Hospital(
            (rand(rng, 1:grid_size[1]), rand(rng, 1:grid_size[2])),
            0
        ) for _ in 1:n_hospitals
    ]
    
    comm_hubs = [
        CommunicationHub(
            (rand(rng, 1:grid_size[1]), rand(rng, 1:grid_size[2])),
            :verbal,
            0
        ) for _ in 1:3
    ]
    
    # Model properties
    properties = CivilizationProperties(
        libraries,
        hospitals,
        comm_hubs,
        0,  # step
        0,  # generation
        Dict(:verbal => 0, :direct => 0, :telepathic => 0),
        Dict(:library => Int[], :hospital => Int[], :comm_hub => Int[]),
        true,  # allow protocol evolution
        true   # allow infrastructure deprecation
    )
    
    # Create model
    model = StandardABM(
        Citizen,
        space;
        agent_step! = citizen_step!,
        model_step! = civilization_step!,
        properties = properties,
        rng = rng
    )
    
    # Add agents
    for id in 1:n_agents
        pos = (rand(rng, 1:grid_size[1]), rand(rng, 1:grid_size[2]))
        agent = create_citizen(id, pos)
        add_agent_pos!(agent, model)
    end
    
    return model
end

# Step function for individual citizens
function citizen_step!(agent::Citizen, model)
    if !agent.alive
        return
    end
    
    # Age the agent
    agent.age += 1
    
    # Manage energy
    manage_energy!(agent, model)
    
    if !agent.alive
        return
    end
    
    # Decide and execute action
    action = decide_action(agent, model)
    agent.last_action = action
    
    if action == :seek_energy
        # Move to random position and gain energy
        walk!(agent, rand, model)
        agent.energy += 20.0
        
    elseif action == :seek_knowledge
        # Check if near library
        nearest_lib = find_nearest_library(agent, model)
        if distance(agent.pos, nearest_lib.pos) < 5
            acquire_knowledge!(agent, :library, model)
        else
            # Move toward library
            move_toward!(agent, nearest_lib.pos, model)
        end
        
    elseif action == :socialize
        # Find nearby agents and share knowledge
        nearby = collect(nearby_agents(agent, model, 2))
        if !isempty(nearby)
            peer = rand(nearby)
            share_knowledge!(agent, peer, model)
        end
        
    elseif action == :optimize_behavior
        # Evolve communication protocols
        evolve_protocol!(agent, model)
    end
end

# Model-level step function
function civilization_step!(model)
    model.step += 1
    
    # Track generation (100 steps = 1 year, 100 years = 1 generation)
    if model.step % 10000 == 0
        model.generation += 1
        analyze_generation!(model)
    end
    
    # Track infrastructure usage every 100 steps
    if model.step % 100 == 0
        track_infrastructure_usage!(model)
    end
    
    # Check for infrastructure deprecation
    if model.allow_infrastructure_deprecation && model.step % 1000 == 0
        check_infrastructure_relevance!(model)
    end
end

# Find nearest library to agent
function find_nearest_library(agent::Citizen, model)
    min_dist = Inf
    nearest = model.libraries[1]
    
    for lib in model.libraries
        d = distance(agent.pos, lib.pos)
        if d < min_dist
            min_dist = d
            nearest = lib
        end
    end
    
    return nearest
end

# Calculate distance between positions
function distance(pos1::NTuple{2,Int}, pos2::NTuple{2,Int})
    return sqrt((pos1[1] - pos2[1])^2 + (pos1[2] - pos2[2])^2)
end

# Move agent toward a target position
function move_toward!(agent::Citizen, target::NTuple{2,Int}, model)
    dx = sign(target[1] - agent.pos[1])
    dy = sign(target[2] - agent.pos[2])
    
    new_pos = (agent.pos[1] + dx, agent.pos[2] + dy)
    
    # Check bounds
    if 1 <= new_pos[1] <= size(model.space)[1] && 
       1 <= new_pos[2] <= size(model.space)[2]
        move_agent!(agent, new_pos, model)
    end
end

# Track infrastructure usage over time
function track_infrastructure_usage!(model)
    lib_usage = sum(agent.library_visits for agent in allagents(model) if agent.alive)
    push!(model.infrastructure_usage[:library], lib_usage)
    
    # Track communication hub usage based on protocol adoption
    verbal_count = count(a -> a.social_protocol == :verbal && a.alive, allagents(model))
    push!(model.infrastructure_usage[:comm_hub], verbal_count)
end

# Check if infrastructure is becoming irrelevant
function check_infrastructure_relevance!(model)
    # If library usage drops significantly, mark for potential removal
    if length(model.infrastructure_usage[:library]) > 10
        recent_usage = model.infrastructure_usage[:library][end-9:end]
        if mean(recent_usage) < 5  # Very low usage
            println("Generation $(model.generation): Libraries becoming obsolete - usage < 5")
        end
    end
    
    # If most agents have evolved past verbal communication, comm hubs might change
    telepathic_ratio = count(a -> a.social_protocol == :telepathic && a.alive, allagents(model)) / 
                      count(a -> a.alive, allagents(model))
    
    if telepathic_ratio > 0.5
        println("Generation $(model.generation): Verbal communication hubs deprecated - $(round(telepathic_ratio*100, digits=1))% telepathic")
    end
end

# Analyze each generation
function analyze_generation!(model)
    agents = collect(allagents(model))
    alive_agents = filter(a -> a.alive, agents)
    
    if isempty(alive_agents)
        println("\nGeneration $(model.generation): Civilization extinct")
        return
    end
    
    avg_knowledge = mean(length(a.knowledge) for a in alive_agents)
    avg_age = mean(a.age for a in alive_agents)
    
    protocol_dist = Dict(
        :verbal => count(a -> a.social_protocol == :verbal, alive_agents),
        :direct => count(a -> a.social_protocol == :direct, alive_agents),
        :telepathic => count(a -> a.social_protocol == :telepathic, alive_agents)
    )
    
    println("\n" * "="^60)
    println("GENERATION $(model.generation) ANALYSIS (Year $(model.step ÷ 100))")
    println("="^60)
    println("Population: $(length(alive_agents))")
    println("Average Knowledge Items: $(round(avg_knowledge, digits=2))")
    println("Average Age: $(round(avg_age, digits=1))")
    println("\nCommunication Protocols:")
    for (protocol, count) in protocol_dist
        pct = round(100 * count / length(alive_agents), digits=1)
        println("  $protocol: $count ($pct%)")
    end
    
    println("\nInfrastructure Usage:")
    total_lib_visits = sum(a.library_visits for a in alive_agents)
    println("  Library visits: $total_lib_visits")
    
    println("\nKnowledge Transfers by Protocol:")
    for (protocol, count) in model.knowledge_transfers
        println("  $protocol: $count")
    end
    println("="^60)
end

export initialize_civilization, citizen_step!, civilization_step!
export analyze_generation!