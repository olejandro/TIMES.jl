using JuMP

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
@variable(
    model,
    ComPrd[r in REGION, t in MILEYR, c in get(R_C, r, Set()), s in TSLICE] >= 0
)
@variable(
    model,
    ComNet[r in REGION, t in MILEYR, c in get(R_C, r, Set()), s in TSLICE] >= 0
)
@variable(
    model,
    PrcCap_bounds(r, v, p, "LO") <=
    PrcCap[r in REGION, v in MODLYR, p in get(R_P, r, Set())] <=
    PrcCap_bounds(r, v, p, "UP")
)
@variable(
    model,
    PrcNcap_bounds(r, v, p, "LO") <=
    PrcNcap[r in REGION, v in MODLYR, p in get(R_P, r, Set())] <=
    PrcNcap_bounds(r, v, p, "UP")
)
@variable(
    model,
    PrcAct[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in get(RTV_PRC, (r, t, v), Set()),
        s in get(RP_TS, (r, p), Set());
        ((r, t, p) in RTP_VARA),
    ] >= 0
)

#PrcAct[(r, v, t, p, s) in filters["var_PrcAct"]] >= 0

@variable(
    model,
    PrcFlo[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in get(RTV_PRC, (r, t, v), Set()),
        c in get(RP_C, (r, p), Set()),
        s in get(RPC_TS, (r, p, c), Set());
        ((r, p) in RP_FLO) && ((r, t, p) in RTP_VARA),
    ] >= 0
)
@variable(
    model,
    IreFlo[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in get(RTV_PRC, (r, t, v), Set()),
        c in get(RP_C, (r, p), Set()),
        s in get(RP_TS, (r, p), Set()),
        ie in IMPEXP;
        ((r, p) in RP_IRE) && ((r, t, p) in RTP_VARA) && ((r, p, c, ie) in RPC_IRE),
    ] >= 0
)
@variable(
    model,
    StgFlo[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in get(RTV_PRC, (r, t, v), Set()),
        c in get(RP_C, (r, p), Set()),
        s in get(RP_TS, (r, p), Set()),
        io in INOUT;
        ((r, p) in RP_STG) && ((r, t, p) in RTP_VARA) && ((r, p, c, io) in TOP),
    ] >= 0
)
