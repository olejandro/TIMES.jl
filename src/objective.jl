# Requires JuMP

function create_objective!(model, data)
    RegObj = model[:RegObj]
    JuMP.@objective(
        model,
        Min,
        sum(RegObj[o,r,cur] for o in OBV for (r, cur) in data[:RDCUR]),
    )
    return
end
