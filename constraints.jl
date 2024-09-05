using JuMP

# Objective function constituents
@constraint(
    model,
    EQ_OBJINV[r in REGION, cur in CURRENCY; (r, cur) in RDCUR],
    sum(
        (
            OBJ_PVT[r, t, cur] *
            COEF_CPT[r, v, t, p] *
            COEF_OBINV[r, v, p, cur] *
            (
                (v in MILEYR ? PrcNcap[r, v, p] : 0) +
                ([r, v, p] in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, v, p] : 0)
            )
        ) for (r, v, t, p) in RTP_CPTYR if (r, v, p, cur) in eachindex(COEF_OBINV)
    ) == RegObj["OBJINV", r, cur]
)

@constraint(
    model,
    EQ_OBJFIX[r in REGION, cur in CURRENCY; (r, cur) in RDCUR],
    sum(
        (
            OBJ_PVT[r, t, cur] *
            COEF_CPT[r, v, t, p] *
            COEF_OBFIX[r, v, p, cur] *
            (
                (v in MILEYR ? PrcNcap[r, v, p] : 0) +
                ([r, v, p] in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, v, p] : 0)
            )
        ) for (r, v, t, p) in RTP_CPTYR if (r, v, p, cur) in eachindex(COEF_OBFIX)
    ) == RegObj["OBJFIX", r, cur]
)

@constraint(
    model,
    EQ_OBJVAR[r in REGION, cur in CURRENCY; (r, cur) in RDCUR],
    sum(
        sum(
            (
                (r, p, cur, t) in eachindex(OBJ_ACOST) ?
                sum(
                    OBJ_LINT[r, t, y, cur] * OBJ_ACOST[r, p, cur, y] for
                    y in LINTY[r, t, cur]
                ) * sum(
                    PrcAct[r, v, t, p, s] * ((r, p) in RP_STG ? RS_STGAV[r, s] : 1) for
                    v in RTP_VNT[r, t, p] for s in RP_TS[r, p]
                ) : 0
            ) + (
                (r, t, p, cur) in RTP_IPRI ?
                sum(
                    sum(
                        OBJ_LINT[r, t, y, cur] * OBJ_IPRIC[r, y, p, c, s, ie, cur] for
                        y in LINTY[r, t, cur]
                    ) * sum(IreFlo[r, v, t, p, c, s, ie] for v in RTP_VNT[r, t, p]) for
                    s in RP_TS[r, p] for (c, ie) in RP_CIE[r, p]
                ) : 0
            ) for t in MILEYR if (r, t, p) in RTP_VARA
        ) for p in PROCESS if (r, p) in RP
    ) == RegObj["OBJVAR", r, cur]
)

# %% Activity to Primary Group
@constraint(
    model,
    EQ_ACTFLO[
        r in REGION,
        v in MODLYR,
        t in MILEYR,
        p in PROCESS,
        s in TSLICE;
        (r, v, t, p) in RTP_VINTYR && (r, p) in PRC_ACT && s in RP_TS[r, p],
    ],
    ((r, t, p) in RTP_VARA ? PrcAct[r, v, t, p, s] : 0) == sum(
        (
            (r, p) in RP_IRE ?
            sum(IreFlo[r, v, t, p, c, s, ie] for ie in IMPEXP if (r, p, ie) in RP_AIRE) :
            PrcFlo[r, v, t, p, c, s]
        ) for c in RP_PGC[r, p]
    )
)

# %% Activity to Capacity
@constraint(
    model,
    EQL_CAPACT[
        r in REGION,
        v in MODLYR,
        y in MILEYR,
        p in PROCESS,
        s in TSLICE;
        (r, v, y, p) in RTP_VINTYR &&
        (r, y, p, "UP") in eachindex(RTP_AFS) &&
        s in RTP_AFS[r, y, p, "UP"],
    ],
    (
        (r, p) in RP_STG ?
        sum(
            PrcAct[r, v, y, p, ts] *
            RS_FR[r, ts, s] *
            exp(isnothing(PRC_SC) ? 0 : PRC_SC[r, p]) / RS_STGPRD[r, s] for
            ts in RP_TS[r, p] if (r, s, ts) in eachindex(RS_FR)
        ) :
        sum(PrcAct[r, v, y, p, ts] for ts in RP_TS[r, p] if (r, s, ts) in eachindex(RS_FR))
    ) <= (
        ((r, p) in RP_STG ? 1 : G_YRFR[r, s]) *
        PRC_CAPACT[r, p] *
        (
            COEF_AF[r, v, y, p, s, "UP"] *
            COEF_CPT[r, v, y, p] *
            (
                (r, p) in PRC_VINT ?
                (
                    (MILE[v] * PrcNcap[r, v, p]) +
                    ((r, v, p) in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, v, p] : 0)
                ) :
                sum(
                    COEF_AF[r, m, y, p, s, "UP"] *
                    COEF_CPT[r, m, y, p] *
                    (
                        (MILE[m] * PrcNcap[r, m, p]) +
                        ((r, m, p) in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, m, p] : 0)
                    ) for m in RTP_CPT[r, y, p]
                )
            )
        )
    )
)

@constraint(
    model,
    EQE_CAPACT[
        r in REGION,
        v in MODLYR,
        y in MILEYR,
        p in PROCESS,
        s in TSLICE;
        (r, v, y, p) in RTP_VINTYR &&
        (r, y, p, "FX") in eachindex(RTP_AFS) &&
        s in RTP_AFS[r, y, p, "FX"],
    ],
    (
        (r, p) in RP_STG ?
        sum(
            PrcAct[r, v, y, p, ts] *
            RS_FR[r, ts, s] *
            exp(isnothing(PRC_SC) ? 0 : PRC_SC[r, p]) / RS_STGPRD[r, s] for
            ts in RP_TS[r, p] if (r, s, ts) in eachindex(RS_FR)
        ) :
        sum(PrcAct[r, v, y, p, ts] for ts in RP_TS[r, p] if (r, s, ts) in eachindex(RS_FR))
    ) == (
        ((r, p) in RP_STG ? 1 : G_YRFR[r, s]) *
        PRC_CAPACT[r, p] *
        (
            COEF_AF[r, v, y, p, s, "FX"] *
            COEF_CPT[r, v, y, p] *
            (
                (r, p) in PRC_VINT ? ((MILE[v] * PrcNcap[r, v, p]) + NCAP_PASTI[r, v, p]) :
                sum(
                    COEF_AF[r, m, y, p, s, "FX"] *
                    COEF_CPT[r, m, y, p] *
                    ((MILE[m] * PrcNcap[r, m, p]) + NCAP_PASTI[r, m, p]) for
                    m in RTP_CPT[r, y, p]
                )
            )
        )
    )
)

# %% Capacity Transfer
@constraint(
    model,
    EQE_CPT[
        r in REGION,
        y in MODLYR,
        p in PROCESS;
        (r, y, p) in RTP &&
        ((r, y, p) in RTP_VARP || (r, y, p, "FX") in eachindex(CAP_BND)),
    ],
    ((r, y, p) in RTP_VARP ? PrcCap[r, y, p] : CAP_BND[r, y, p, "FX"]) == sum(
        COEF_CPT[r, v, y, p] * (
            (MILE[v] * PrcNcap[r, v, p]) +
            ((r, v, p) in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, v, p] : 0)
        ) for v in RTP_CPT[r, y, p]
    )
)

@constraint(
    model,
    EQL_CPT[
        r in REGION,
        y in MODLYR,
        p in PROCESS;
        (r, y, p) in RTP &&
        (!((r, y, p) in RTP_VARP) && (r, y, p, "LO") in eachindex(CAP_BND)),
    ],
    ((r, y, p) in RTP_VARP ? PrcCap[r, y, p] : CAP_BND[r, y, p, "LO"]) <= sum(
        COEF_CPT[r, v, y, p] * (
            (MILE[v] * PrcNcap[r, v, p]) +
            ((r, v, p) in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, v, p] : 0)
        ) for v in RTP_CPT[r, y, p]
    )
)

@constraint(
    model,
    EQG_CPT[
        r in REGION,
        y in MODLYR,
        p in PROCESS;
        (r, y, p) in RTP &&
        (!((r, y, p) in RTP_VARP) && (r, y, p, "UP") in eachindex(CAP_BND)),
    ],
    ((r, y, p) in RTP_VARP ? PrcCap[r, y, p] : CAP_BND[r, y, p, "UP"]) >= sum(
        COEF_CPT[r, v, y, p] * (
            (MILE[v] * PrcNcap[r, v, p]) +
            ((r, v, p) in eachindex(NCAP_PASTI) ? NCAP_PASTI[r, v, p] : 0)
        ) for v in RTP_CPT[r, y, p]
    )
)

# %% Process Flow Shares
@constraint(
    model,
    EQL_FLOSHR[
        r in REGION,
        v in MODLYR,
        p in PROCESS,
        c in COMMTY,
        cg in COMGRP,
        s in TSLICE,
        l in ["LO"],
        t in MILEYR;
        (r, v, p, c, cg, s, l) in eachindex(FLO_SHAR) &&
        (r, t, p) in RTP_VARA &&
        v in RTP_VNT[r, t, p] &&
        s in RPC_TS[r, p, c],
    ],
    sum(
        FLO_SHAR[r, v, p, c, cg, s, l] * sum(
            PrcFlo[r, v, t, p, com, ts] * RS_FR[r, s, ts] for com in RPIO_C[r, p, io] for
            ts in RPC_TS[r, p, com] if
            ((r, cg, com) in COM_GMAP && (r, s, ts) in eachindex(RS_FR))
        ) for io in INOUT if c in RPIO_C[r, p, io]
    ) <= PrcFlo[r, v, t, p, c, s]
)

@constraint(
    model,
    EQG_FLOSHR[
        r in REGION,
        v in MODLYR,
        p in PROCESS,
        c in COMMTY,
        cg in COMGRP,
        s in TSLICE,
        l in ["UP"],
        t in MILEYR;
        (r, v, p, c, cg, s, l) in eachindex(FLO_SHAR) &&
        (r, t, p) in RTP_VARA &&
        v in RTP_VNT[r, t, p] &&
        s in RPC_TS[r, p, c],
    ],
    sum(
        FLO_SHAR[r, v, p, c, cg, s, l] * sum(
            PrcFlo[r, v, t, p, com, ts] * RS_FR[r, s, ts] for com in RPIO_C[r, p, io] for
            ts in RPC_TS[r, p, com] if
            ((r, cg, com) in COM_GMAP && (r, s, ts) in eachindex(RS_FR))
        ) for io in INOUT if c in RPIO_C[r, p, io]
    ) >= PrcFlo[r, v, t, p, c, s]
)

@constraint(
    model,
    EQE_FLOSHR[
        r in REGION,
        v in MODLYR,
        p in PROCESS,
        c in COMMTY,
        cg in COMGRP,
        s in TSLICE,
        l in ["FX"],
        t in MILEYR;
        (r, v, p, c, cg, s, l) in eachindex(FLO_SHAR) &&
        (r, t, p) in RTP_VARA &&
        v in RTP_VNT[r, t, p] &&
        s in RPC_TS[r, p, c],
    ],
    (sum(
        FLO_SHAR[r, v, p, c, cg, s, l] * sum(
            PrcFlo[r, v, t, p, com, ts] * RS_FR[r, s, ts] for com in RPIO_C[r, p, io] for
            ts in RPC_TS[r, p, com] if
            ((r, cg, com) in COM_GMAP && (r, s, ts) in eachindex(RS_FR))
        ) for io in INOUT if c in RPIO_C[r, p, io]
    ) == PrcFlo[r, v, t, p, c, s])
)

# %% Activity efficiency:
@constraint(
    model,
    EQE_ACTEFF[
        r in REGION,
        p in PROCESS,
        cg in COMGRP,
        io in INOUT,
        t in MILEYR,
        v in MODLYR,
        s in TSLICE;
        !isnothing(RPG_ACE) &&
        (r, p, cg, io) in RPG_ACE &&
        s in RP_S1[r, p] &&
        (r, t, p) in RTP_VARA &&
        v in RTP_VNT[r, t, p],
    ],
    (!isnothing(RP_ACE) ?
    sum(
        sum(
            PrcFlo[r, v, t, p, c, ts] *
            ((r, v, p, c, ts) in eachindex(ACT_EFF) ? ACT_EFF[r, v, p, c, ts] : 1) *
            RS_FR[r, s, ts] *
            (1 + RTCS_FR[r, t, c, s, ts]) for
            ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
        ) for c in RP_ACE[r, p] if (r, cg, c) in COM_GMAP
    ) :
    0) == sum(
        RS_FR[r, s, ts] * (
            (r, p) in RP_PGFLO ?
            sum(
                (
                    (r, p) in RP_PGACT ? PrcAct[r, v, t, p, ts] :
                    PrcFlo[r, v, t, p, c, ts] / PRC_ACTFLO[r, v, p, c]
                ) / ((r, v, p, c, ts) in eachindex(ACT_EFF) ? ACT_EFF[r, v, p, c, ts] : 1) *
                (1 + RTCS_FR[r, t, c, s, ts]) for c in RP_PGC[r, p]
            ) : PrcAct[r, v, t, p, ts]
        ) / max(1e-6, ACT_EFF[r, v, p, cg, ts]) for
        ts in RP_TS[r, p] if (r, s, ts) in eachindex(RS_FR)
    )
)

# %% Process Transformation
@constraint(
    model,
    EQ_PTRANS[
        r in REGION,
        p in PROCESS,
        cg1 in COMGRP,
        cg2 in COMGRP,
        s1 in TSLICE,
        t in MILEYR,
        v in MODLYR,
        s in TSLICE;
        (r, p, cg1, cg2, s1) in RP_PTRAN &&
        (r, s1, s) in eachindex(RS_FR) &&
        s in RP_S1[r, p] &&
        (r, t, p) in RTP_VARA &&
        v in RTP_VNT[r, t, p],
    ],
    sum(
        sum(
            PrcFlo[r, v, t, p, c, ts] *
            RS_FR[r, s, ts] *
            (1 + ((r, t, c, s, ts) in eachindex(RTCS_FR) ? RTCS_FR[r, t, c, s, ts] : 0)) for
            ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
        ) for io in INOUT for c in RPIO_C[r, p, io] if (r, cg2, c) in COM_GMAP
    ) == sum(
        COEF_PTRAN[r, v, p, cg1, c, cg2, ts] *
        RS_FR[r, s, ts] *
        (1 + ((r, t, c, s, ts) in eachindex(RTCS_FR) ? RTCS_FR[r, t, c, s, ts] : 0)) *
        PrcFlo[r, v, t, p, c, ts] for io in INOUT for c in RPIO_C[r, p, io] for
        ts in RPC_TS[r, p, c] if (
            (r, s, ts) in eachindex(RS_FR) ?
            ((r, v, p, cg1, c, cg2, ts) in eachindex(COEF_PTRAN) ? true : false) : false
        )
    )
)

# %% Commodity Balance - Greater
@constraint(
    model,
    EQG_COMBAL[
        r in REGION,
        t in MILEYR,
        c in COMMTY,
        s in TSLICE;
        (r, t, c, s, "LO") in RCS_COMBAL,
    ],
    (
        !isnothing(RHS_COMPRD) && ((r, t, c, s) in RHS_COMPRD) ? ComPrd[r, t, c, s] :
        (
            (
                (r, c, "OUT") in eachindex(RCIO_P) ?
                sum(
                    (
                        (r, p, c) in RPC_STG ?
                        sum(
                            sum(
                                StgFlo[r, v, t, p, c, ts, "OUT"] *
                                RS_FR[r, s, ts] *
                                (
                                    1 + (
                                        (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                        RTCS_FR[r, t, c, s, ts] : 0
                                    )
                                ) *
                                STG_EFF[r, v, p] for v in RTP_VNT[r, t, p]
                            ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                        ) :
                        sum(
                            sum(
                                PrcFlo[r, v, t, p, c, ts] *
                                RS_FR[r, s, ts] *
                                (
                                    1 + (
                                        (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                        RTCS_FR[r, t, c, s, ts] : 0
                                    )
                                ) for v in RTP_VNT[r, t, p]
                            ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                        )
                    ) for p in RCIO_P[r, c, "OUT"] if (r, t, p) in RTP_VARA
                ) : 0
            ) + (
                (r, c, "IMP") in eachindex(RCIE_P) ?
                sum(
                    sum(
                        sum(
                            IreFlo[r, v, t, p, c, ts, "IMP"] *
                            RS_FR[r, s, ts] *
                            (
                                1 + (
                                    (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                    RTCS_FR[r, t, c, s, ts] : 0
                                )
                            ) for v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                    ) for p in RCIE_P[r, c, "IMP"] if (r, t, p) in RTP_VARA
                ) : 0
            )
        ) * COM_IE[r, t, c, s]
    ) >=
    (
        (r, c, "IN") in eachindex(RCIO_P) ?
        sum(
            (
                (r, p, c) in RPC_STG ?
                sum(
                    sum(
                        StgFlo[r, v, t, p, c, ts, "IN"] *
                        RS_FR[r, s, ts] *
                        (
                            1 + (
                                (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                RTCS_FR[r, t, c, s, ts] : 0
                            )
                        ) for v in RTP_VNT[r, t, p]
                    ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                ) :
                (sum(
                    sum(
                        PrcFlo[r, v, t, p, c, ts] *
                        RS_FR[r, s, ts] *
                        (
                            1 + (
                                (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                RTCS_FR[r, t, c, s, ts] : 0
                            )
                        ) for v in RTP_VNT[r, t, p]
                    ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                ))
            ) for p in RCIO_P[r, c, "IN"] if (r, t, p) in RTP_VARA
        ) : 0
    ) +
    (
        (r, c, "EXP") in eachindex(RCIE_P) ?
        sum(
            sum(
                sum(
                    IreFlo[r, v, t, p, c, ts, "EXP"] *
                    RS_FR[r, s, ts] *
                    (
                        1 + (
                            (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                            RTCS_FR[r, t, c, s, ts] : 0
                        )
                    ) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
            ) for p in RCIE_P[r, c, "EXP"] if (r, t, p) in RTP_VARA
        ) : 0
    ) +
    ((r, t, c) in eachindex(COM_PROJ) ? COM_PROJ[r, t, c] * COM_FR[r, t, c, s] : 0)
)

# %% Commodity Balance - Equal
@constraint(
    model,
    EQE_COMBAL[
        r in REGION,
        t in MILEYR,
        c in COMMTY,
        s in TSLICE;
        (r, t, c, s, "FX") in RCS_COMBAL,
    ],
    (
        !isnothing(RHS_COMPRD) && ((r, t, c, s) in RHS_COMPRD) ? ComPrd[r, t, c, s] :
        (
            sum(
                (
                    (r, p, c) in RPC_STG ?
                    sum(
                        sum(
                            StgFlo[r, v, t, p, c, ts, "OUT"] *
                            RS_FR[r, s, ts] *
                            (
                                1 + (
                                    (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                    RTCS_FR[r, t, c, s, ts] : 0
                                )
                            ) *
                            STG_EFF[r, v, p] for v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                    ) :
                    (sum(
                        sum(
                            PrcFlo[r, v, t, p, c, ts] *
                            RS_FR[r, s, ts] *
                            (
                                1 + (
                                    (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                    RTCS_FR[r, t, c, s, ts] : 0
                                )
                            ) for v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                    ))
                ) for p in RCIO_P[r, c, "OUT"] if (r, t, p) in RTP_VARA
            ) + sum(
                sum(
                    sum(
                        IreFlo[r, v, t, p, c, ts, "IMP"] *
                        RS_FR[r, s, ts] *
                        (
                            1 + (
                                (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                                RTCS_FR[r, t, c, s, ts] : 0
                            )
                        ) for v in RTP_VNT[r, t, p]
                    ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
                ) for p in RCIE_P[r, c, "IMP"] if (r, t, p) in RTP_VARA
            )
        ) * COM_IE[r, t, c, s]
    ) ==
    sum(
        (
            (r, p, c) in RPC_STG ?
            sum(
                sum(
                    StgFlo[r, v, t, p, c, ts, "IN"] *
                    RS_FR[r, s, ts] *
                    (
                        1 + (
                            (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                            RTCS_FR[r, t, c, s, ts] : 0
                        )
                    ) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
            ) :
            (sum(
                sum(
                    PrcFlo[r, v, t, p, c, ts] *
                    RS_FR[r, s, ts] *
                    (
                        1 + (
                            (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                            RTCS_FR[r, t, c, s, ts] : 0
                        )
                    ) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
            ))
        ) for p in RCIO_P[r, c, "IN"] if (r, t, p) in RTP_VARA
    ) +
    sum(
        sum(
            sum(
                IreFlo[r, v, t, p, c, ts, "EXP"] *
                RS_FR[r, s, ts] *
                (1 + ((r, t, c, s, ts) in eachindex(RTCS_FR) ? RTCS_FR[r, t, c, s, ts] : 0))
                for v in RTP_VNT[r, t, p]
            ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
        ) for p in RCIE_P[r, c, "EXP"] if (r, t, p) in RTP_VARA
    ) +
    RHS_COMBAL[r, t, c, s] * ComNet[r, t, c, s] +
    ((r, t, c) in eachindex(COM_PROJ) ? COM_PROJ[r, t, c] * COM_FR[r, t, c, s] : 0)
)

# %% Commodity Production
@constraint(
    model,
    EQE_COMPRD[
        r in REGION,
        t in MILEYR,
        c in COMMTY,
        s in TSLICE;
        !isnothing(RCS_COMPRD) && (r, t, c, s, "FX") in RCS_COMPRD,
    ],
    sum(
        (
            (r, p, c) in RPC_STG ?
            sum(
                sum(
                    StgFlo[r, v, t, p, c, ts, "OUT"] *
                    RS_FR[r, s, ts] *
                    (
                        1 + (
                            (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                            RTCS_FR[r, t, c, s, ts] : 0
                        )
                    ) *
                    STG_EFF[r, v, p] for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
            ) :
            sum(
                sum(
                    PrcFlo[r, v, t, p, c, ts] *
                    RS_FR[r, s, ts] *
                    (
                        1 + (
                            (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                            RTCS_FR[r, t, c, s, ts] : 0
                        )
                    ) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
            )
        ) + sum(
            sum(
                sum(
                    IreFlo[r, v, t, p, c, ts, "IMP"] *
                    RS_FR[r, s, ts] *
                    (
                        1 + (
                            (r, t, c, s, ts) in eachindex(RTCS_FR) ?
                            RTCS_FR[r, t, c, s, ts] : 0
                        )
                    ) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c] if (r, s, ts) in eachindex(RS_FR)
            ) for p in RCIE_P[r, c, "IMP"] if (r, t, p) in RTP_VARA
        ) for p in RCIO_P[r, c, "OUT"] if (r, t, p) in RTP_VARA
    ) * COM_IE[r, t, c, s] == ComPrd[r, t, c, s]
)

# %% Timeslice Storage Transformation
@constraint(
    model,
    EQ_STGTSS[
        r in REGION,
        v in MODLYR,
        y in MILEYR,
        p in PROCESS,
        s in TSLICE;
        (r, v, y, p) in RTP_VINTYR && (r, p, s) in RPS_STG,
    ],
    PrcAct[r, v, y, p, s] == sum(
        (
            PrcAct[r, v, y, p, all_s] +
            ((r, y, p, all_s) in eachindex(STG_CHRG) ? STG_CHRG[r, y, p, all_s] : 0) +
            sum(
                StgFlo[r, v, y, p, c, all_s, io] / PRC_ACTFLO[r, v, p, c] *
                (io == "IN" ? 1 : -1) for (r, p, c, io) in TOP if (r, p, c) in PRC_STGTSS
            ) +
            (PrcAct[r, v, y, p, s] + PrcAct[r, v, y, p, all_s]) / 2 * (
                (
                    1 - exp(
                        min(
                            0,
                            (
                                !isnothing(STG_LOSS) &&
                                (r, v, p, all_s) in eachindex(STG_LOSS) ?
                                STG_LOSS[r, v, p, all_s] : 0
                            ),
                        ) * G_YRFR[r, all_s] / RS_STGPRD[r, s],
                    )
                ) +
                max(
                    0,
                    (
                        !isnothing(STG_LOSS) && (r, v, p, all_s) in eachindex(STG_LOSS) ?
                        STG_LOSS[r, v, p, all_s] : 0
                    ),
                ) * G_YRFR[r, all_s] / RS_STGPRD[r, s]
            )
        ) for all_s in TSLICE if (r, s, all_s) in RS_PRETS
    )
)
