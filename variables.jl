using JuMP

function PrcCap_bounds(r, y, p, bd)
    if (r, y, p, bd) in eachindex(CAP_BND)
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
    if (r, y, p, bd) in eachindex(NCAP_BND)
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
@variable(model, ComPrd[REGION, MILEYR, COMMTY, TSLICE] >= 0)
@variable(model, ComNet[REGION, MILEYR, COMMTY, TSLICE] >= 0)
@variable(
    model,
    PrcCap_bounds(r, y, p, "LO") <=
    PrcCap[r in REGION, y in MODLYR, p in PROCESS] <=
    PrcCap_bounds(r, y, p, "UP")
)
@variable(
    model,
    PrcNcap_bounds(r, y, p, "LO") <=
    PrcNcap[r in REGION, y in MODLYR, p in PROCESS] <=
    PrcNcap_bounds(r, y, p, "UP")
)
@variable(model, PrcAct[REGION, MODLYR, MILEYR, PROCESS, TSLICE] >= 0)
@variable(model, PrcFlo[REGION, MODLYR, MILEYR, PROCESS, COMMTY, TSLICE] >= 0)
@variable(model, IreFlo[REGION, MODLYR, MILEYR, PROCESS, COMMTY, TSLICE, IMPEXP] >= 0)
@variable(model, StgFlo[REGION, MODLYR, MILEYR, PROCESS, COMMTY, TSLICE, INOUT] >= 0)
