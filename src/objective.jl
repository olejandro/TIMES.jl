# Requires JuMP

function create_objective(model)
    @expression(model, obj, sum(RegObj[o, r, cur] for o in OBV for (r, cur) in RDCUR))
    @objective(model, Min, obj)
end
