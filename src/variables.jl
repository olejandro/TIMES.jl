# Requires JuMP

function PrcCap_bounds(r, y, p, bd)
    if haskey(CAP_BND, (r, y, p, bd))
        return CAP_BND[r, y, p, bd]
    end
    if bd == "LO"
        return 0
    end
    if bd == "UP"
        return Inf
    end
end

function PrcNcap_bounds(r, y, p, bd)
    if haskey(NCAP_BND, (r, y, p, bd))
        return NCAP_BND[r, y, p, bd]
    end
    if bd == "LO"
        return 0
    end
    if bd == "UP"
        return Inf
    end
end

function create_variables(model, indices)
    # %% Variables
    global RegObj = @variable(model, RegObj[OBV, REGION, CURRENCY] >= 0)
    global ComPrd = @variable(model, ComPrd[(r, t, c, s) in indices["var_ComPrd"]] >= 0)
    global ComNet = @variable(model, ComNet[(r, t, c, s) in indices["var_ComNet"]] >= 0)
    global PrcCap = @variable(
        model,
        PrcCap_bounds(r, v, p, "LO") <=
        PrcCap[(r, v, p) in indices["var_PrcCap"]] <=
        PrcCap_bounds(r, v, p, "UP")
    )
    global PrcNcap = @variable(
        model,
        PrcNcap_bounds(r, v, p, "LO") <=
        PrcNcap[(r, v, p) in indices["var_PrcCap"]] <=
        PrcNcap_bounds(r, v, p, "UP")
    )
    global PrcAct = @variable(model, PrcAct[(r, v, t, p, s) in indices["var_PrcAct"]] >= 0)
    global PrcFlo =
        @variable(model, PrcFlo[(r, v, t, p, c, s) in indices["var_PrcFlo"]] >= 0)
    global IreFlo =
        @variable(model, IreFlo[(r, v, t, p, c, s, ie) in indices["var_IreFlo"]] >= 0)
    global StgFlo =
        @variable(model, StgFlo[(r, v, t, p, c, s, io) in indices["var_StgFlo"]] >= 0)
end
