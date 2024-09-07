using JuMP;
using HiGHS;
#using GAMS;

model = Model()

# %% Steps to run the model
steps = [
    Dict("path" => "sets.jl", "description" => "Define sets"),
    Dict("path" => "demo-data.jl", "description" => "Load demo data (sets and parameters)"),
    Dict("path" => "parameters.jl", "description" => "Compute additional parameters"),
    Dict("path" => "compute-sets.jl", "description" => "Compute additional sets"),
    Dict("path" => "variables.jl", "description" => "Create Variables"),
    Dict("path" => "objective.jl", "description" => "Objective Function"),
    Dict("path" => "constraints.jl", "description" => "Specify constraints"),
]

# %% Execute steps and print progress
for step in steps
    @time step["description"] include(step["path"])
end

# Set solver
set_optimizer(model, HiGHS.Optimizer)
#set_optimizer(model, GAMS.Optimizer)
#set_optimizer_attribute(model, GAMS.Solver(), "CPLEX")

@time "Solve model" optimize!(model)

# Print solution summary
solution_summary(model)
