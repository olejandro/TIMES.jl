module TIMES

export create_model

using JuMP
using DataFrames
using SQLite

function __init__()
    # Nothing yet!
end

# Define TIMES sets
include("./sets.jl")
# Functions to read data from database
include("./load_data.jl")
# Compute additional sets
include("./compute_sets.jl")
# Compute additional parameters
include("./parameters.jl")
# Compute indexes for equations and variables
include("./compute_indexes.jl")
# Create Variables
include("./variables.jl")
# Define objective Function
include("./objective.jl")
# Generate constraints
include("./constraints.jl")


function create_model(file_path)

    model = Model()

    data = read_data(file_path)
    create_read_symbols(data)
    create_parameters()
    compute_sets(data)
    indices = compute_indexes(data)
    create_variables(model, indices)
    create_objective(model)
    create_constraints(model, indices)

    return model

end

end
