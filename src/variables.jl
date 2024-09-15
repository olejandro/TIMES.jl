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

# %% Variables
@variable(model, RegObj[OBV, REGION, CURRENCY] >= 0)
@variable(model, ComPrd[(r, t, c, s) in indices["var_ComPrd"]] >= 0)
@variable(model, ComNet[(r, t, c, s) in indices["var_ComNet"]] >= 0)
@variable(
    model,
    PrcCap_bounds(r, v, p, "LO") <=
    PrcCap[(r, v, p) in indices["var_PrcCap"]] <=
    PrcCap_bounds(r, v, p, "UP")
)
@variable(
    model,
    PrcNcap_bounds(r, v, p, "LO") <=
    PrcNcap[(r, v, p) in indices["var_PrcCap"]] <=
    PrcNcap_bounds(r, v, p, "UP")
)
@variable(model, PrcAct[(r, v, t, p, s) in indices["var_PrcAct"]] >= 0)
@variable(model, PrcFlo[(r, v, t, p, c, s) in indices["var_PrcFlo"]] >= 0)
@variable(model, IreFlo[(r, v, t, p, c, s, ie) in indices["var_IreFlo"]] >= 0)
@variable(model, StgFlo[(r, v, t, p, c, s, io) in indices["var_StgFlo"]] >= 0)
