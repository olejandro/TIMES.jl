using JuMP

# Objective function constituents
@constraint(
    model,
    EQ_OBJINV[(r, cur) in RDCUR],
    sum(
        (
            OBJ_PVT[r, t, cur] *
            COEF_CPT[r, v, t, p] *
            get(COEF_OBINV, (r, v, p, cur), 0) *
            ((v in MILEYR ? PrcNcap[(r, v, p)] : 0) + get(NCAP_PASTI, (r, v, p), 0))
        ) for (v, t, p) in R_CPT[r]
    ) == RegObj["OBJINV", r, cur]
)

@constraint(
    model,
    EQ_OBJFIX[(r, cur) in RDCUR],
    sum(
        (
            OBJ_PVT[r, t, cur] *
            COEF_CPT[r, v, t, p] *
            get(COEF_OBFIX, (r, v, p, cur), 0) *
            ((v in MILEYR ? PrcNcap[(r, v, p)] : 0) + get(NCAP_PASTI, (r, v, p), 0))
        ) for (v, t, p) in R_CPT[r]
    ) == RegObj["OBJFIX", r, cur]
)

@constraint(
    model,
    EQ_OBJVAR[(r, cur) in RDCUR],
    sum(
        sum(
            sum(
                OBJ_LINT[r, t, y, cur] * get(OBJ_ACOST, (r, p, cur, y), 0) for
                y in LINTY[r, t, cur]
            ) * sum(
                PrcAct[(r, v, t, p, s)] * ((r, p) in RP_STG ? RS_STGAV[r, s] : 1) for
                v in get(RTP_VNT, (r, t, p), Set()) for s in RP_TS[r, p]
            ) + (
                (r, t, p, cur) in RTP_IPRI ?
                sum(
                    sum(
                        OBJ_LINT[r, t, y, cur] * OBJ_IPRIC[r, y, p, c, s, ie, cur] for
                        y in LINTY[r, t, cur]
                    ) * sum(IreFlo[(r, v, t, p, c, s, ie)] for v in get(RTP_VNT, (r, t, p), Set())) for
                    s in RP_TS[r, p] for (c, ie) in RP_CIE[r, p]
                ) : 0
            ) for t in MILEYR if (r, t, p) in RTP_VARA
        ) for p in R_P[r]
    ) == RegObj["OBJVAR", r, cur]
)

# %% Activity to Primary Group
@constraint(
    model,
    EQ_ACTFLO[(r, v, t, p, s) in indices["EQ_ACTFLO"]],
    ((r, t, p) in RTP_VARA ? PrcAct[(r, v, t, p, s)] : 0) == sum(
        (
            (r, p) in RP_IRE ?
            sum(IreFlo[(r, v, t, p, c, s, ie)] for ie in IMPEXP if (r, p, ie) in RP_AIRE) :
            PrcFlo[(r, v, t, p, c, s)]
        ) for c in RP_PGC[r, p]
    )
)

# %% Activity to Capacity
@constraint(
    model,
    EQL_CAPACT[(r, v, y, p, s) in indices["EQL_CAPACT"],],
    (
        (r, p) in RP_STG ?
        sum(
            PrcAct[(r, v, y, p, ts)] *
            RS_FR[r, ts, s] *
            exp(isnothing(PRC_SC) ? 0 : get(PRC_SC,(r, p),0)) / RS_STGPRD[r, s] for
            ts in RP_TS[r, p] if haskey(RS_FR, (r, s, ts))
        ) :
        sum(PrcAct[(r, v, y, p, ts)] for ts in RP_TS[r, p] if haskey(RS_FR, (r, s, ts)))
    ) <= (
        ((r, p) in RP_STG ? 1 : G_YRFR[r, s]) *
        PRC_CAPACT[r, p] *
        (
            (r, p) in PRC_VINT ?
            COEF_AF[r, v, y, p, s, "UP"] *
            COEF_CPT[r, v, y, p] *
            (MILE[v] * PrcNcap[(r, v, p)] + get(NCAP_PASTI, (r, v, p), 0)) :
            sum(
                COEF_AF[r, m, y, p, s, "UP"] *
                COEF_CPT[r, m, y, p] *
                ((MILE[m] * PrcNcap[(r, m, p)]) + get(NCAP_PASTI, (r, m, p), 0)) for
                m in RTP_CPT[r, y, p]
            )
        )
    )
)


@constraint(
    model,
    EQE_CAPACT[(r, v, y, p, s) in indices["EQE_CAPACT"]],
    (
        (r, p) in RP_STG ?
        sum(
            PrcAct[(r, v, y, p, ts)] *
            RS_FR[r, ts, s] *
            exp(isnothing(PRC_SC) ? 0 : PRC_SC[r, p]) / RS_STGPRD[r, s] for
            ts in RP_TS[r, p] if haskey(RS_FR, (r, s, ts))
        ) : sum(PrcAct[(r, v, y, p, ts)] for ts in RP_TS[r, p] if haskey(RS_FR, (r, s, ts)))
    ) == (
        ((r, p) in RP_STG ? 1 : G_YRFR[r, s]) *
        PRC_CAPACT[r, p] *
        (
            (r, p) in PRC_VINT ?
            COEF_AF[r, v, y, p, s, "FX"] *
            COEF_CPT[r, v, y, p] *
            (MILE[v] * PrcNcap[(r, v, p)] + get(NCAP_PASTI, (r, v, p), 0)) :
            sum(
                COEF_AF[r, m, y, p, s, "FX"] *
                COEF_CPT[r, m, y, p] *
                ((MILE[m] * PrcNcap[(r, m, p)]) + get(NCAP_PASTI, (r, m, p),0)) for
                m in RTP_CPT[r, y, p]
            )
        )
    )
)

# %% Capacity Transfer
@constraint(
    model,
    EQE_CPT[
        (r, y, p) in RTP;
        (r, y, p) in RTP_VARP || haskey(CAP_BND, (r, y, p, "FX"))
    ],
    ((r, y, p) in RTP_VARP ? PrcCap[(r, y, p)] : CAP_BND[r, y, p, "FX"]) == sum(
        COEF_CPT[r, v, y, p] *
        ((MILE[v] * PrcNcap[(r, v, p)]) + get(NCAP_PASTI, (r, v, p), 0)) for
        v in get(RTP_CPT, (r, y, p), Set())
    )
)

@constraint(
    model,
    EQL_CPT[
        (r, y, p) in RTP;
        !((r, y, p) in RTP_VARP) && haskey(CAP_BND, (r, y, p, "LO"))
    ],
    ((r, y, p) in RTP_VARP ? PrcCap[(r, y, p)] : CAP_BND[r, y, p, "LO"]) <= sum(
        COEF_CPT[r, v, y, p] *
        ((MILE[v] * PrcNcap[(r, v, p)]) + get(NCAP_PASTI, (r, v, p), 0)) for
        v in get(RTP_CPT, (r, y, p), Set())
    )
)

@constraint(
    model,
    EQG_CPT[
        (r, y, p) in RTP;
        !((r, y, p) in RTP_VARP) && haskey(CAP_BND, (r, y, p, "UP"))
    ],
    ((r, y, p) in RTP_VARP ? PrcCap[(r, y, p)] : CAP_BND[r, y, p, "UP"]) >= sum(
        COEF_CPT[r, v, y, p] *
        ((MILE[v] * PrcNcap[(r, v, p)]) + get(NCAP_PASTI, (r, v, p), 0)) for
        v in get(RTP_CPT, (r, y, p), Set())
    )
)

# %% Process Flow Shares
@expression(
    model,
    EXPR_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EXPR_FLOSHR"]],
    sum(
        FLO_SHAR[r, v, p, c, cg, s, l] * sum(
            PrcFlo[(r, v, t, p, com, ts)] * get(RS_FR, (r, s, ts), 0) for
            com in RPIO_C[r, p, io] for ts in RPC_TS[r, p, c] if (r, cg, com) in COM_GMAP
        ) for io in INOUT if c in RPIO_C[r, p, io]
    )
)

@constraint(
    model,
    EQL_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EQL_FLOSHR"]],
    EXPR_FLOSHR[(r, v, p, c, cg, s, l, t)] <= PrcFlo[(r, v, t, p, c, s)]
)

@constraint(
    model,
    EQG_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EQG_FLOSHR"]],
    EXPR_FLOSHR[(r, v, p, c, cg, s, l, t)] >= PrcFlo[(r, v, t, p, c, s)]
)

@constraint(
    model,
    EQE_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EQE_FLOSHR"]],
    EXPR_FLOSHR[(r, v, p, c, cg, s, l, t)] == PrcFlo[(r, v, t, p, c, s)]
)


# %% Activity efficiency:
@constraint(
    model,
    EQE_ACTEFF[(r, p, cg, io, t, v, s) in indices["EQE_ACTEFF"]],
    (
        !isnothing(RP_ACE) ?
        sum(
            sum(
                PrcFlo[(r, v, t, p, c, ts)] *
                get(ACT_EFF, (r, v, p, c, ts), 1) *
                get(RS_FR, (r, s, ts), 0) *
                (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for ts in RPC_TS[r, p, c]
            ) for c in RP_ACE[r, p] if (r, cg, c) in COM_GMAP
        ) : 0
    ) == sum(
        get(RS_FR, (r, s, ts), 0) * (
            (r, p) in RP_PGFLO ?
            sum(
                (
                    (r, p) in RP_PGACT ? PrcAct[(r, v, t, p, ts)] :
                    PrcFlo[(r, v, t, p, c, ts)] / PRC_ACTFLO[r, v, p, c]
                ) / get(ACT_EFF, (r, v, p, c, ts), 1) * (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for
                c in RP_PGC[r, p]
            ) : PrcAct[(r, v, t, p, ts)]
        ) / max(1e-6, get(ACT_EFF, (r, v, p, c, ts), 1)) for ts in RP_TS[r, p]
    )
)

# %% Process Transformation
@constraint(
    model,
    EQ_PTRANS[(r, p, cg1, cg2, s1, t, v, s) in indices["EQ_PTRANS"]],
    sum(
        sum(
            PrcFlo[(r, v, t, p, c, ts)] *
            get(RS_FR, (r, s, ts), 0) *
            (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for ts in RPC_TS[r, p, c]
        ) for io in INOUT for c in RPIO_C[r, p, io] if (r, cg2, c) in COM_GMAP
    ) == sum(
        get(COEF_PTRAN, (r, v, p, cg1, c, cg2, ts), 0) *
        get(RS_FR, (r, s, ts), 0) *
        (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) *
        PrcFlo[(r, v, t, p, c, ts)] for io in INOUT for c in RPIO_C[r, p, io] for
        ts in RPC_TS[r, p, c]
    )
)

# %% Commodity Balance - Greater

@constraint(
    model,
    EQG_COMBAL[(r, t, c, s) in indices["EQG_COMBAL"]],
    (
        !isnothing(RHS_COMPRD) && ((r, t, c, s) in RHS_COMPRD) ? ComPrd[(r, t, c, s)] :
        (
            sum(
                (
                    (r, p, c) in RPC_STG ?
                    sum(
                        sum(
                            StgFlo[(r, v, t, p, c, ts, "OUT")] *
                            get(RS_FR, (r, s, ts), 0) *
                            (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) *
                            STG_EFF[r, v, p] for v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c]
                    ) :
                    sum(
                        sum(
                            PrcFlo[(r, v, t, p, c, ts)] *
                            get(RS_FR, (r, s, ts), 0) *
                            (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for
                            v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c]
                    )
                ) for p in get(RCIO_P, (r, c, "OUT"), Set()) if (r, t, p) in RTP_VARA;
                init = 0,
            ) + sum(
                sum(
                    sum(
                        IreFlo[(r, v, t, p, c, ts, "IMP")] *
                        get(RS_FR, (r, s, ts), 0) *
                        (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                    ) for ts in RPC_TS[r, p, c]
                ) for p in get(RCIE_P, (r, c, "IMP"), Set()) if (r, t, p) in RTP_VARA;
                init = 0,
            )
        ) * COM_IE[r, t, c, s]
    ) >=
    sum(
        (
            (r, p, c) in RPC_STG ?
            sum(
                sum(
                    StgFlo[(r, v, t, p, c, ts, "IN")] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            ) :
            (sum(
                sum(
                    PrcFlo[(r, v, t, p, c, ts)] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            ))
        ) for p in get(RCIO_P, (r, c, "IN"), Set()) if (r, t, p) in RTP_VARA;
        init = 0,
    ) +
    sum(
        sum(
            sum(
                IreFlo[(r, v, t, p, c, ts, "EXP")] *
                get(RS_FR, (r, s, ts), 0) *
                (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
            ) for ts in RPC_TS[r, p, c]
        ) for p in get(RCIE_P, (r, c, "EXP"), Set()) if (r, t, p) in RTP_VARA;
        init = 0,
    ) +
    get(COM_PROJ, (r, t, c), 0) * COM_FR[r, t, c, s]
)

# %% Commodity Balance - Equal
@constraint(
    model,
    EQE_COMBAL[(r, t, c, s) in indices["EQE_COMBAL"]],
    (
        !isnothing(RHS_COMPRD) && ((r, t, c, s) in RHS_COMPRD) ? ComPrd[(r, t, c, s)] :
        (
            sum(
                (
                    (r, p, c) in RPC_STG ?
                    sum(
                        sum(
                            StgFlo[(r, v, t, p, c, ts, "OUT")] *
                            get(RS_FR, (r, s, ts), 0) *
                            (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) *
                            STG_EFF[r, v, p] for v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c]
                    ) :
                    (sum(
                        sum(
                            PrcFlo[(r, v, t, p, c, ts)] *
                            get(RS_FR, (r, s, ts), 0) *
                            (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for
                            v in RTP_VNT[r, t, p]
                        ) for ts in RPC_TS[r, p, c]
                    ))
                ) for p in RCIO_P[r, c, "OUT"] if (r, t, p) in RTP_VARA
            ) + sum(
                sum(
                    sum(
                        IreFlo[(r, v, t, p, c, ts, "IMP")] *
                        get(RS_FR, (r, s, ts), 0) *
                        (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                    ) for ts in RPC_TS[r, p, c]
                ) for p in RCIE_P[r, c, "IMP"] if (r, t, p) in RTP_VARA
            )
        ) * COM_IE[r, t, c, s]
    ) ==
    sum(
        (
            (r, p, c) in RPC_STG ?
            sum(
                sum(
                    StgFlo[(r, v, t, p, c, ts, "IN")] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            ) :
            (sum(
                sum(
                    PrcFlo[(r, v, t, p, c, ts)] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            ))
        ) for p in RCIO_P[r, c, "IN"] if (r, t, p) in RTP_VARA
    ) +
    sum(
        sum(
            sum(
                IreFlo[(r, v, t, p, c, ts, "EXP")] *
                get(RS_FR, (r, s, ts), 0) *
                (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
            ) for ts in RPC_TS[r, p, c]
        ) for p in RCIE_P[r, c, "EXP"] if (r, t, p) in RTP_VARA
    ) +
    RHS_COMBAL[r, t, c, s] * ComNet[(r, t, c, s)] +
    get(COM_PROJ, (r, t, c), 0) * COM_FR[r, t, c, s]
)

# %% Commodity Production
@constraint(
    model,
    EQE_COMPRD[(r, t, c, s) in indices["EQE_COMPRD"]],
    sum(
        (
            (r, p, c) in RPC_STG ?
            sum(
                sum(
                    StgFlo[(r, v, t, p, c, ts, "OUT")] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) *
                    STG_EFF[r, v, p] for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            ) :
            sum(
                sum(
                    PrcFlo[(r, v, t, p, c, ts)] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            )
        ) + sum(
            sum(
                sum(
                    IreFlo[(r, v, t, p, c, ts, "IMP")] *
                    get(RS_FR, (r, s, ts), 0) *
                    (1 + (!isnothing(RTCS_FR) ? get(RTCS_FR, (r, t, c, s, ts), 0) : 0)) for v in RTP_VNT[r, t, p]
                ) for ts in RPC_TS[r, p, c]
            ) for p in RCIE_P[r, c, "IMP"] if (r, t, p) in RTP_VARA
        ) for p in RCIO_P[r, c, "OUT"] if (r, t, p) in RTP_VARA
    ) * COM_IE[r, t, c, s] == ComPrd[(r, t, c, s)]
)

# %% Timeslice Storage Transformation
@constraint(
    model,
    EQ_STGTSS[(r, v, y, p, s) in indices["EQ_STGTSS"]],
    PrcAct[(r, v, y, p, s)] == sum(
        (
            PrcAct[(r, v, y, p, all_s)] +
            get(STG_CHRG, (r, y, p, all_s), 0) +
            sum(
                StgFlo[(r, v, y, p, c, all_s, io)] / PRC_ACTFLO[r, v, p, c] *
                (io == "IN" ? 1 : -1) for (r, p, c, io) in TOP if (r, p, c) in PRC_STGTSS
            ) +
            (PrcAct[(r, v, y, p, s)] + PrcAct[(r, v, y, p, all_s)]) / 2 * (
                (
                    1 - exp(
                        min(
                            0,
                            (!isnothing(STG_LOSS) ? get(STG_LOSS, (r, v, p, all_s), 0) : 0),
                        ) * G_YRFR[r, all_s] / RS_STGPRD[r, s],
                    )
                ) +
                max(0, (!isnothing(STG_LOSS) ? get(STG_LOSS, (r, v, p, all_s), 0) : 0)) *
                G_YRFR[r, all_s] / RS_STGPRD[r, s]
            )
        ) for all_s in TSLICE if (r, s, all_s) in RS_PRETS
    )
)
