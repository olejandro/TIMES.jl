# Requires JuMP

# Define additional parameters
function create_parameters!(model, data)
    JuMP.JuMP.@expression(
        model,
        MILE[y in data[:MODLYR]],
        y in data[:MILEYR] ? 1 : 0,
    )
    return
end
