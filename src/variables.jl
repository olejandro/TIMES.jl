# Requires JuMP

function create_variables!(model, indices, read_symbols)
    lb(k, i) = get(read_symbols[k], tuple(i..., "LB"), 0.0)
    ub(k, i) = get(read_symbols[k], tuple(i..., "UB"), Inf)
    JuMP.JuMP.@variables(model, begin
        RegObj[OBV, read_symbols[:REGION], read_symbols[:CURRENCY]] >= 0
        ComPrd[indices["var_ComPrd"]] >= 0
        ComNet[indices["var_ComNet"]] >= 0
        lb(:CAP_BND, i) <= PrcCap[i in indices["var_PrcCap"]] <= ub(:CAP_BND, i)
        lb(:NCAP_BND, i) <= PrcNcap[i in indices["var_PrcCap"]] <= ub(:NCAP_BND, i)
        PrcAct[indices["var_PrcAct"]] >= 0
        PrcFlo[indices["var_PrcFlo"]] >= 0
        IreFlo[indices["var_IreFlo"]] >= 0
        StgFlo[indices["var_StgFlo"]] >= 0
    end)
    return
end
