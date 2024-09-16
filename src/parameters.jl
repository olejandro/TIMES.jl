# Requires JuMP

# Define additional parameters
function create_parameters()
    global Containers.@container(MILE[y in MODLYR], y in MILEYR ? 1 : 0)
end
