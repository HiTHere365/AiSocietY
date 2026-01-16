"""
Main simulation runner for the civilization experiment.
Run this to start the simulation and generate analytics.
"""

include("agents.jl")
include("model.jl")

using Agents
using DataFrames
using Statistics
using Plots
using JSON3

function run_simulation(;
    n_agents::Int = 100,
    n_steps::Int = 10000,  # 100 years (100 steps per year)
    generations::Int = 1,   # How many 100-year generations to simulate
    output_dir::String = "results"
)
    
    println("="^60)
    println("CIVILIZATION SIMULATION")
    println("="^60)
    println("Agents: $n_agents")
    println("Total Generations: $generations")
    println("Steps per generation: $n_steps")
    println("="^60)
    
    # Create output directory
    mkpath(output_dir)
    
    # Initialize model
    model = initialize_civilization(
        n_agents = n_agents,
        grid_size = (50, 50),
        n_libraries = 5,
        n_hospitals = 3
    )
    
    # Data collection
    adata = [
        :energy,
        :age,
        :alive,
        :social_protocol,
        :library_visits,
        :knowledge_shared
    ]
    
    agent_data, model_data = run!(
        model,
        n_steps * generations;
        adata = adata,
        when = 1:100:n_steps*generations  # Collect every 100 steps
    )
    
    # Generate analytics
    generate_analytics(agent_data, model, output_dir)
    
    return model, agent_data
end

function generate_analytics(agent_data::DataFrame, model, output_dir::String)
    println("\n\nGenerating analytics...")
    
    # Filter alive agents only
    alive_data = filter(row -> row.alive, agent_data)
    
    if isempty(alive_data)
        println("Warning: No agents survived")
        return
    end
    
    # 1. Plot protocol evolution over time
    steps = unique(alive_data.time)
    protocol_evolution = Dict(
        :verbal => Int[],
        :direct => Int[],
        :telepathic => Int[]
    )
    
    for step in steps
        step_data = filter(row -> row.time == step, alive_data)
        for protocol in [:verbal, :direct, :telepathic]
            count = nrow(filter(row -> row.social_protocol == protocol, step_data))
            push!(protocol_evolution[protocol], count)
        end
    end
    
    p1 = plot(
        steps, [protocol_evolution[:verbal], protocol_evolution[:direct], protocol_evolution[:telepathic]],
        label = ["Verbal" "Direct Transfer" "Telepathic"],
        xlabel = "Simulation Step",
        ylabel = "Number of Agents",
        title = "Communication Protocol Evolution",
        linewidth = 2,
        legend = :right
    )
    savefig(p1, joinpath(output_dir, "protocol_evolution.png"))
    
    # 2. Library usage over time
    p2 = plot(
        model.infrastructure_usage[:library],
        xlabel = "Time (×100 steps)",
        ylabel = "Total Library Visits",
        title = "Library Usage Decline",
        linewidth = 2,
        color = :red,
        legend = false
    )
    savefig(p2, joinpath(output_dir, "library_usage.png"))
    
    # 3. Knowledge accumulation
    knowledge_by_step = Dict{Int, Float64}()
    for step in steps
        step_data = filter(row -> row.time == step, alive_data)
        # Note: We can't directly access knowledge set size from DataFrame
        # This would need to be added as a computed metric
        # For now, use library_visits as proxy
        knowledge_by_step[step] = mean(step_data.library_visits)
    end
    
    p3 = plot(
        collect(keys(knowledge_by_step)),
        collect(values(knowledge_by_step)),
        xlabel = "Simulation Step",
        ylabel = "Avg Library Visits per Agent",
        title = "Knowledge Seeking Behavior",
        linewidth = 2,
        color = :green,
        legend = false
    )
    savefig(p3, joinpath(output_dir, "knowledge_seeking.png"))
    
    # 4. Summary statistics
    summary = Dict(
        "total_steps" => maximum(agent_data.time),
        "final_population" => nrow(filter(row -> row.time == maximum(agent_data.time), alive_data)),
        "protocol_distribution" => Dict(
            "verbal" => protocol_evolution[:verbal][end],
            "direct" => protocol_evolution[:direct][end],
            "telepathic" => protocol_evolution[:telepathic][end]
        ),
        "total_knowledge_transfers" => model.knowledge_transfers,
        "library_total_visits" => sum(model.infrastructure_usage[:library])
    )
    
    # Save JSON summary
    open(joinpath(output_dir, "summary.json"), "w") do f
        write(f, JSON3.write(summary, allow_inf = true))
    end
    
    println("✓ Analytics saved to $output_dir")
    println("\nKey Findings:")
    println("  Final Population: $(summary["final_population"])")
    println("  Total Library Visits: $(summary["library_total_visits"])")
    
    protocol_dist = summary["protocol_distribution"]
    total = sum(values(protocol_dist))
    if total > 0
        for (protocol, count) in protocol_dist
            pct = round(100 * count / total, digits=1)
            println("  $protocol: $count ($pct%)")
        end
    end
end

# Quick test run
function quick_test()
    println("Running quick test (1000 steps)...")
    model = initialize_civilization(n_agents = 50)
    step!(model, 1000)
    println("\n✓ Test complete!")
    return model
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    # Run a full simulation
    model, data = run_simulation(
        n_agents = 100,
        n_steps = 10000,  # 100 years
        generations = 2    # 200 years total
    )
end

export run_simulation, quick_test, generate_analytics