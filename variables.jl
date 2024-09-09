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
    PrcCap_bounds(r, v, p, "LO") <=
    PrcCap[r in REGION, v in MODLYR, p in PROCESS] <=
    PrcCap_bounds(r, v, p, "UP")
)
@variable(
    model,
    PrcNcap_bounds(r, v, p, "LO") <=
    PrcNcap[r in REGION, v in MODLYR, p in PROCESS] <=
    PrcNcap_bounds(r, v, p, "UP")
)
@variable(
    model,
    PrcAct[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in PROCESS,
        s in TSLICE;
        ((r, t, p) in RTP_VARA) && ((r, v, t, p) in RTP_VINTYR) && ((r, p, s) in PRC_TS),
    ] >= 0
)
@variable(
    model,
    PrcFlo[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in PROCESS,
        c in COMMTY,
        s in TSLICE;
        ((r, p) in RP_FLO) &&
        ((r, t, p) in RTP_VARA) &&
        ((r, v, t, p) in RTP_VINTYR) &&
        ((r, p, c) in RPC) &&
        ((r, p, c, s) in RPCS_VAR),
    ] >= 0
)
@variable(
    model,
    IreFlo[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in PROCESS,
        c in COMMTY,
        s in TSLICE,
        ie in IMPEXP;
        ((r, p) in RP_IRE) &&
        ((r, t, p) in RTP_VARA) &&
        ((r, v, t, p) in RTP_VINTYR) &&
        ((r, p, c) in RPC) &&
        ((r, p, s) in PRC_TS) &&
        ((r, p, c, ie) in RPC_IRE),
    ] >= 0
)
@variable(
    model,
    StgFlo[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in PROCESS,
        c in COMMTY,
        s in TSLICE,
        io in INOUT;
        ((r, p) in RP_STG) &&
        ((r, t, p) in RTP_VARA) &&
        ((r, v, t, p) in RTP_VINTYR) &&
        ((r, p, c) in RPC) &&
        ((r, p, s) in PRC_TS) &&
        ((r, p, c, io) in TOP),
    ] >= 0
)
