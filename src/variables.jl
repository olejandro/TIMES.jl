# Requires JuMP

function create_variables!(model, indices, data)
    lo(k, i) = get(data[k], tuple(i..., "LO"), 0.0)
    up(k, i) = get(data[k], tuple(i..., "UP"), Inf)
    JuMP.@variables(model, begin
        RegObj[OBV, data[:REGION], data[:CURRENCY]] >= 0
        ComPrd[indices["var_ComPrd"]] >= 0
        ComNet[indices["var_ComNet"]] >= 0
        lo(:CAP_BND, i) <= PrcCap[i in indices["var_PrcCap"]] <= up(:CAP_BND, i)
        lo(:NCAP_BND, i) <= PrcNcap[i in indices["var_PrcCap"]] <= up(:NCAP_BND, i)
        PrcAct[indices["var_PrcAct"]] >= 0
        PrcFlo[indices["var_PrcFlo"]] >= 0
        IreFlo[indices["var_IreFlo"]] >= 0
        StgFlo[indices["var_StgFlo"]] >= 0
    end)
    return
end
