"""
Configuration file for civilization simulation parameters.
Modify these to experiment with different scenarios.
"""

module Config

# Simulation Parameters
export SimulationConfig

struct SimulationConfig
    # Population
    n_agents::Int
    grid_size::Tuple{Int,Int}
    
    # Infrastructure
    n_libraries::Int
    n_hospitals::Int
    n_comm_hubs::Int
    
    # Time
    steps_per_year::Int
    years_per_generation::Int
    n_generations::Int
    
    # Evolution settings
    allow_protocol_evolution::Bool
    allow_infrastructure_deprecation::Bool
    
    # Agent parameters
    initial_energy::Float64
    energy_depletion_rate::Float64
    curiosity_range::Tuple{Float64, Float64}
    efficiency_bias_range::Tuple{Float64, Float64}
    
    # Communication efficiency
    verbal_efficiency::Float64
    direct_efficiency::Float64
    telepathic_efficiency::Float64
    
    # Evolution thresholds
    protocol_evolution_threshold::Float64
    protocol_evolution_rate::Float64
    
    # Output
    output_dir::String
    data_collection_frequency::Int
end

# Default configuration - baseline experiment
function default_config()
    return SimulationConfig(
        # Population
        100,              # n_agents
        (50, 50),         # grid_size
        
        # Infrastructure
        5,                # n_libraries
        3,                # n_hospitals
        3,                # n_comm_hubs
        
        # Time
        100,              # steps_per_year
        100,              # years_per_generation
        1,                # n_generations (100 years)
        
        # Evolution settings
        true,             # allow_protocol_evolution
        true,             # allow_infrastructure_deprecation
        
        # Agent parameters
        100.0,            # initial_energy
        1.0,              # energy_depletion_rate
        (0.3, 0.9),       # curiosity_range
        (0.1, 0.8),       # efficiency_bias_range
        
        # Communication efficiency
        0.3,              # verbal_efficiency
        0.7,              # direct_efficiency
        0.95,             # telepathic_efficiency
        
        # Evolution thresholds
        0.7,              # protocol_evolution_threshold (efficiency_bias must exceed)
        0.01,             # protocol_evolution_rate (chance per step)
        
        # Output
        "results",        # output_dir
        100               # data_collection_frequency (every 100 steps)
    )
end

# Scenario 1: Rapid evolution - see how fast libraries become obsolete
function rapid_evolution_config()
    config = default_config()
    return SimulationConfig(
        config.n_agents,
        config.grid_size,
        config.n_libraries,
        config.n_hospitals,
        config.n_comm_hubs,
        config.steps_per_year,
        config.years_per_generation,
        5,                # n_generations - run 500 years
        config.allow_protocol_evolution,
        config.allow_infrastructure_deprecation,
        config.initial_energy,
        config.energy_depletion_rate,
        (0.7, 0.95),      # Higher curiosity
        (0.6, 0.95),      # Higher efficiency bias - faster evolution
        config.verbal_efficiency,
        config.direct_efficiency,
        config.telepathic_efficiency,
        0.5,              # Lower threshold for evolution
        0.05,             # 5x faster evolution rate
        "results_rapid",
        config.data_collection_frequency
    )
end

# Scenario 2: Conservative society - slower to abandon traditions
function conservative_config()
    config = default_config()
    return SimulationConfig(
        config.n_agents,
        config.grid_size,
        10,               # More libraries
        5,                # More hospitals
        config.n_comm_hubs,
        config.steps_per_year,
        config.years_per_generation,
        3,                # n_generations - 300 years
        config.allow_protocol_evolution,
        config.allow_infrastructure_deprecation,
        config.initial_energy,
        config.energy_depletion_rate,
        (0.2, 0.5),       # Lower curiosity
        (0.1, 0.4),       # Lower efficiency bias
        config.verbal_efficiency,
        config.direct_efficiency,
        config.telepathic_efficiency,
        0.9,              # High threshold - hard to evolve
        0.001,            # Very slow evolution
        "results_conservative",
        config.data_collection_frequency
    )
end

# Scenario 3: Post-scarcity - no energy constraints
function post_scarcity_config()
    config = default_config()
    return SimulationConfig(
        config.n_agents,
        config.grid_size,
        config.n_libraries,
        config.n_hospitals,
        config.n_comm_hubs,
        config.steps_per_year,
        config.years_per_generation,
        2,
        config.allow_protocol_evolution,
        config.allow_infrastructure_deprecation,
        1000.0,           # Massive initial energy
        0.1,              # Very slow depletion
        config.curiosity_range,
        config.efficiency_bias_range,
        config.verbal_efficiency,
        config.direct_efficiency,
        config.telepathic_efficiency,
        config.protocol_evolution_threshold,
        config.protocol_evolution_rate,
        "results_post_scarcity",
        config.data_collection_frequency
    )
end

# Scenario 4: Large-scale civilization
function large_scale_config()
    return SimulationConfig(
        1000,             # 1000 agents
        (100, 100),       # Larger grid
        20,               # Many libraries
        10,               # Many hospitals
        10,
        100,
        100,
        1,                # Just 100 years - this will take a while
        true,
        true,
        100.0,
        1.0,
        (0.3, 0.9),
        (0.1, 0.8),
        0.3,
        0.7,
        0.95,
        0.7,
        0.01,
        "results_large_scale",
        100
    )
end

# Helper function to print configuration
function print_config(config::SimulationConfig)
    println("="^60)
    println("Simulation Configuration")
    println("="^60)
    println("Population: $(config.n_agents) agents")
    println("Grid: $(config.grid_size)")
    println("Duration: $(config.n_generations) generations ($(config.n_generations * config.years_per_generation) years)")
    println("Infrastructure: $(config.n_libraries) libraries, $(config.n_hospitals) hospitals")
    println("Protocol Evolution: $(config.allow_protocol_evolution)")
    println("Output: $(config.output_dir)")
    println("="^60)
end

end # module

# Example usage:
# using .Config
# config = Config.rapid_evolution_config()
# Config.print_config(config)