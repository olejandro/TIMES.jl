module TIMES

export create_model

import DataFrames
import JuMP
import PrecompileTools
import SQLite

# Define TIMES sets
include("sets.jl")
# Functions to read data from database
include("load_data.jl")
# Compute additional sets
include("compute_sets.jl")
# Compute additional parameters
include("parameters.jl")
# Compute indexes for equations and variables
include("compute_indexes.jl")
# Create Variables
include("variables.jl")
# Define objective Function
include("objective.jl")
# Generate constraints
include("constraints.jl")

function create_model(file_path)
    # Read data
    df_data = read_data(file_path)
    sets = compute_sets(df_data)
    indices = compute_indexes(df_data)
    data = create_read_symbols(df_data)
    # Setup JuMP model
    model = JuMP.Model()
    create_parameters!(model, data)
    create_variables!(model, indices, data)
    create_objective!(model, data)
    create_constraints!(model, indices, data, sets)
    return model
end

PrecompileTools.@setup_workload begin
    PrecompileTools.@compile_workload begin
        create_model("PROTO.db3")
    end
end

end
