# Requires JuMP

function create_constraints!(model, indices, data, sets)
    # Variables
    RegObj = model[:RegObj]
    PrcCap = model[:PrcCap]
    ComPrd = model[:ComPrd]
    ComNet = model[:ComNet]
    PrcNcap = model[:PrcNcap]
    PrcAct = model[:PrcAct]
    PrcFlo = model[:PrcFlo]
    IreFlo = model[:IreFlo]
    StgFlo = model[:StgFlo]
    # Parameters
    MILE = model[:MILE]

    # Objective function constituents
    JuMP.@constraint(
        model,
        EQ_OBJINV[(r, cur) in data[:RDCUR]],
        RegObj["OBJINV", r, cur] == sum(
            data[:OBJ_PVT][r, t, cur] *
            data[:COEF_CPT][r, v, t, p] *
            get(data[:COEF_OBINV], (r, v, p, cur), 0) *
            (
                (v in data[:MILEYR] ? PrcNcap[(r, v, p)] : 0) +
                get(data[:NCAP_PASTI], (r, v, p), 0)
            )
            for (v, t, p) in sets.R_CPT[r]
        )
    )

    JuMP.@constraint(
        model,
        EQ_OBJFIX[(r, cur) in data[:RDCUR]],
        sum(
            (
                data[:OBJ_PVT][r, t, cur] *
                data[:COEF_CPT][r, v, t, p] *
                get(data[:COEF_OBFIX], (r, v, p, cur), 0) *
                ((v in data[:MILEYR] ? PrcNcap[(r, v, p)] : 0) + get(data[:NCAP_PASTI], (r, v, p), 0))
            ) for (v, t, p) in sets.R_CPT[r]
        ) == RegObj["OBJFIX", r, cur]
    )

    JuMP.@constraint(
        model,
        EQ_OBJVAR[(r, cur) in data[:RDCUR]],
        sum(
            sum(
                sum(
                    data[:OBJ_LINT][r, t, y, cur] * get(data[:OBJ_ACOST], (r, p, cur, y), 0) for
                    y in sets.LINTY[r, t, cur]
                ) * sum(
                    PrcAct[(r, v, t, p, s)] * ((r, p) in data[:RP_STG] ? data[:RS_STGAV][r, s] : 1) for
                    v in get(sets.RTP_VNT, (r, t, p), Set()) for s in sets.RP_TS[r, p]
                ) + (
                    (r, t, p, cur) in data[:RTP_IPRI] ?
                    sum(
                        sum(
                            data[:OBJ_LINT][r, t, y, cur] * data[:OBJ_IPRIC][r, y, p, c, s, ie, cur] for
                            y in sets.LINTY[r, t, cur]
                        ) * sum(
                            IreFlo[(r, v, t, p, c, s, ie)] for
                            v in get(sets.RTP_VNT, (r, t, p), Set())
                        ) for s in sets.RP_TS[r, p] for (c, ie) in sets.RP_CIE[r, p]
                    ) : 0
                ) for t in data[:MILEYR] if (r, t, p) in data[:RTP_VARA]
            ) for p in sets.R_P[r]
        ) == RegObj["OBJVAR", r, cur]
    )

    # %% Activity to Primary Group
    JuMP.@constraint(
        model,
        EQ_ACTFLO[(r, v, t, p, s) in indices["EQ_ACTFLO"]],
        ((r, t, p) in data[:RTP_VARA] ? PrcAct[(r, v, t, p, s)] : 0) == sum(
            (
                (r, p) in data[:RP_IRE] ?
                sum(
                    IreFlo[(r, v, t, p, c, s, ie)] for ie in IMPEXP if (r, p, ie) in data[:RP_AIRE]
                ) : PrcFlo[(r, v, t, p, c, s)]
            ) for c in sets.RP_PGC[r, p]
        )
    )

    # %% Activity to Capacity
    JuMP.@constraint(
        model,
        EQL_CAPACT[(r, v, y, p, s) in indices["EQL_CAPACT"]],
        (
            (r, p) in data[:RP_STG] ?
            sum(
                PrcAct[(r, v, y, p, ts)] *
                data[:RS_FR][r, ts, s] *
                exp(isnothing(data[:PRC_SC]) ? 0 : get(data[:PRC_SC], (r, p), 0)) / data[:RS_STGPRD][r, s] for
                ts in sets.RP_TS[r, p] if haskey(data[:RS_FR], (r, s, ts))
            ) :
            sum(
                PrcAct[(r, v, y, p, ts)] for ts in sets.RP_TS[r, p] if haskey(data[:RS_FR], (r, s, ts))
            )
        ) <= (
            ((r, p) in data[:RP_STG] ? 1 : data[:G_YRFR][r, s]) *
            data[:PRC_CAPACT][r, p] *
            (
                (r, p) in data[:PRC_VINT] ?
                data[:COEF_AF][r, v, y, p, s, "UP"] *
                data[:COEF_CPT][r, v, y, p] *
                (MILE[v] * PrcNcap[(r, v, p)] + get(data[:NCAP_PASTI], (r, v, p), 0)) :
                sum(
                    data[:COEF_AF][r, m, y, p, s, "UP"] *
                    data[:COEF_CPT][r, m, y, p] *
                    ((MILE[m] * PrcNcap[(r, m, p)]) + get(data[:NCAP_PASTI], (r, m, p), 0)) for
                    m in sets.RTP_CPT[r, y, p]
                )
            )
        )
    )

    JuMP.@constraint(
        model,
        EQG_CAPACT[(r, v, y, p, s) in indices["EQG_CAPACT"]],
        (
            (r, p) in data[:RP_STG] ?
            sum(
                PrcAct[(r, v, y, p, ts)] *
                data[:RS_FR][r, ts, s] *
                exp(isnothing(data[:PRC_SC]) ? 0 : get(data[:PRC_SC], (r, p), 0)) / data[:RS_STGPRD][r, s] for
                ts in sets.RP_TS[r, p] if haskey(data[:RS_FR], (r, s, ts))
            ) :
            sum(
                PrcAct[(r, v, y, p, ts)] for ts in sets.RP_TS[r, p] if haskey(data[:RS_FR], (r, s, ts))
            )
        ) >= (
            ((r, p) in data[:RP_STG] ? 1 : data[:G_YRFR][r, s]) *
            data[:PRC_CAPACT][r, p] *
            (
                (r, p) in data[:PRC_VINT] ?
                data[:COEF_AF][r, v, y, p, s, "LO"] *
                data[:COEF_CPT][r, v, y, p] *
                (MILE[v] * PrcNcap[(r, v, p)] + get(data[:NCAP_PASTI], (r, v, p), 0)) :
                sum(
                    data[:COEF_AF][r, m, y, p, s, "LO"] *
                    data[:COEF_CPT][r, m, y, p] *
                    ((MILE[m] * PrcNcap[(r, m, p)]) + get(data[:NCAP_PASTI], (r, m, p), 0)) for
                    m in sets.RTP_CPT[r, y, p]
                )
            )
        )
    )

    JuMP.@constraint(
        model,
        EQE_CAPACT[(r, v, y, p, s) in indices["EQE_CAPACT"]],
        (
            (r, p) in data[:RP_STG] ?
            sum(
                PrcAct[(r, v, y, p, ts)] *
                data[:RS_FR][r, ts, s] *
                exp(isnothing(data[:PRC_SC]) ? 0 : data[:PRC_SC][r, p]) / data[:RS_STGPRD][r, s] for
                ts in sets.RP_TS[r, p] if haskey(data[:RS_FR], (r, s, ts))
            ) :
            sum(
                PrcAct[(r, v, y, p, ts)] for ts in sets.RP_TS[r, p] if haskey(data[:RS_FR], (r, s, ts))
            )
        ) == (
            ((r, p) in data[:RP_STG] ? 1 : data[:G_YRFR][r, s]) *
            data[:PRC_CAPACT][r, p] *
            (
                (r, p) in data[:PRC_VINT] ?
                data[:COEF_AF][r, v, y, p, s, "FX"] *
                data[:COEF_CPT][r, v, y, p] *
                (MILE[v] * PrcNcap[(r, v, p)] + get(data[:NCAP_PASTI], (r, v, p), 0)) :
                sum(
                    data[:COEF_AF][r, m, y, p, s, "FX"] *
                    data[:COEF_CPT][r, m, y, p] *
                    ((MILE[m] * PrcNcap[(r, m, p)]) + get(data[:NCAP_PASTI], (r, m, p), 0)) for
                    m in sets.RTP_CPT[r, y, p]
                )
            )
        )
    )

    # %% Capacity Transfer
    JuMP.@constraint(
        model,
        EQE_CPT[
            (r, y, p) in data[:RTP]
            (r, y, p) in data[:RTP_VARP] || haskey(data[:CAP_BND], (r, y, p, "FX"))
        ],
        ((r, y, p) in data[:RTP_VARP] ? PrcCap[(r, y, p)] : data[:CAP_BND][r, y, p, "FX"]) == sum(
            data[:COEF_CPT][r, v, y, p] *
            ((MILE[v] * PrcNcap[(r, v, p)]) + get(data[:NCAP_PASTI], (r, v, p), 0)) for
            v in get(sets.RTP_CPT, (r, y, p), Set())
        )
    )

    JuMP.@constraint(
        model,
        EQL_CPT[
            (r, y, p) in data[:RTP]
            !((r, y, p) in data[:RTP_VARP]) && haskey(data[:CAP_BND], (r, y, p, "LO"))
        ],
        ((r, y, p) in data[:RTP_VARP] ? PrcCap[(r, y, p)] : data[:CAP_BND][r, y, p, "LO"]) <= sum(
            data[:COEF_CPT][r, v, y, p] *
            ((MILE[v] * PrcNcap[(r, v, p)]) + get(data[:NCAP_PASTI], (r, v, p), 0)) for
            v in get(sets.RTP_CPT, (r, y, p), Set())
        )
    )

    JuMP.@constraint(
        model,
        EQG_CPT[
            (r, y, p) in data[:RTP]
            !((r, y, p) in data[:RTP_VARP]) && haskey(data[:CAP_BND], (r, y, p, "UP"))
        ],
        ((r, y, p) in data[:RTP_VARP] ? PrcCap[(r, y, p)] : data[:CAP_BND][r, y, p, "UP"]) >= sum(
            data[:COEF_CPT][r, v, y, p] *
            ((MILE[v] * PrcNcap[(r, v, p)]) + get(data[:NCAP_PASTI], (r, v, p), 0)) for
            v in get(sets.RTP_CPT, (r, y, p), Set())
        )
    )

    # %% Process Flow Shares
    JuMP.@expression(
        model,
        EXPR_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EXPR_FLOSHR"]],
        sum(
            data[:FLO_SHAR][r, v, p, c, cg, s, l] * sum(
                PrcFlo[(r, v, t, p, com, ts)] * get(data[:RS_FR], (r, s, ts), 0) for
                com in sets.RPIO_C[r, p, io] for
                ts in sets.RPC_TS[r, p, c] if (r, cg, com) in data[:COM_GMAP]
            ) for io in INOUT if c in sets.RPIO_C[r, p, io]
        )
    )

    JuMP.@constraint(
        model,
        EQL_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EQL_FLOSHR"]],
        EXPR_FLOSHR[(r, v, p, c, cg, s, l, t)] <= PrcFlo[(r, v, t, p, c, s)]
    )

    JuMP.@constraint(
        model,
        EQG_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EQG_FLOSHR"]],
        EXPR_FLOSHR[(r, v, p, c, cg, s, l, t)] >= PrcFlo[(r, v, t, p, c, s)]
    )

    JuMP.@constraint(
        model,
        EQE_FLOSHR[(r, v, p, c, cg, s, l, t) in indices["EQE_FLOSHR"]],
        EXPR_FLOSHR[(r, v, p, c, cg, s, l, t)] == PrcFlo[(r, v, t, p, c, s)]
    )


    # %% Activity efficiency:
    JuMP.@constraint(
        model,
        EQE_ACTEFF[(r, p, cg, io, t, v, s) in indices["EQE_ACTEFF"]],
        (
            !isnothing(sets.RP_ACE) ?
            sum(
                sum(
                    PrcFlo[(r, v, t, p, c, ts)] *
                    get(data[:ACT_EFF], (r, v, p, c, ts), 1) *
                    get(data[:RS_FR], (r, s, ts), 0) *
                    (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)) for
                    ts in sets.RPC_TS[r, p, c]
                ) for c in sets.RP_ACE[r, p] if (r, cg, c) in data[:COM_GMAP]
            ) : 0
        ) == sum(
            get(data[:RS_FR], (r, s, ts), 0) * (
                (r, p) in data[:RP_PGFLO] ?
                sum(
                    (
                        (r, p) in data[:RP_PGACT] ? PrcAct[(r, v, t, p, ts)] :
                        PrcFlo[(r, v, t, p, c, ts)] / data[:PRC_ACTFLO][r, v, p, c]
                    ) / get(data[:ACT_EFF], (r, v, p, c, ts), 1) *
                    (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)) for
                    c in sets.RP_PGC[r, p]
                ) : PrcAct[(r, v, t, p, ts)]
            ) / max(1e-6, get(data[:ACT_EFF], (r, v, p, cg, ts), 1)) for ts in sets.RP_TS[r, p]
        )
    )

    # %% Process Transformation
    JuMP.@constraint(
        model,
        EQ_PTRANS[(r, p, cg1, cg2, s1, t, v, s) in indices["EQ_PTRANS"]],
        sum(
            sum(
                PrcFlo[(r, v, t, p, c, ts)] *
                get(data[:RS_FR], (r, s, ts), 0) *
                (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)) for
                ts in sets.RPC_TS[r, p, c]
            ) for io in INOUT for c in sets.RPIO_C[r, p, io] if (r, cg2, c) in data[:COM_GMAP]
        ) == sum(
            get(data[:COEF_PTRAN], (r, v, p, cg1, c, cg2, ts), 0) *
            get(data[:RS_FR], (r, s, ts), 0) *
            (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)) *
            PrcFlo[(r, v, t, p, c, ts)] for io in INOUT for c in sets.RPIO_C[r, p, io] for
            ts in sets.RPC_TS[r, p, c]
        )
    )

    # %% Commodity Balance - Greater
    JuMP.@constraint(
        model,
        EQG_COMBAL[(r, t, c, s) in indices["EQG_COMBAL"]],
        (
            !isnothing(data[:RHS_COMPRD]) && ((r, t, c, s) in data[:RHS_COMPRD]) ? ComPrd[(r, t, c, s)] :
            (
                sum(
                    (
                        (r, p, c) in data[:RPC_STG] ?
                        sum(
                            sum(
                                StgFlo[(r, v, t, p, c, ts, "OUT")] *
                                get(data[:RS_FR], (r, s, ts), 0) *
                                (
                                    1 + (
                                        !isnothing(data[:RTCS_FR]) ?
                                        get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0
                                    )
                                ) *
                                data[:STG_EFF][r, v, p] for v in get(sets.RTP_VNT, (r, t, p), Set())
                            ) for ts in sets.RPC_TS[r, p, c]
                        ) :
                        sum(
                            sum(
                                PrcFlo[(r, v, t, p, c, ts)] *
                                get(data[:RS_FR], (r, s, ts), 0) *
                                (
                                    1 + (
                                        !isnothing(data[:RTCS_FR]) ?
                                        get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0
                                    )
                                ) for v in get(sets.RTP_VNT, (r, t, p), Set());
                                init = 0,
                            ) for ts in sets.RPC_TS[r, p, c]
                        )
                    ) for p in get(sets.RCIO_P, (r, c, "OUT"), Set()) if (r, t, p) in data[:RTP_VARA];
                    init = 0,
                ) + sum(
                    sum(
                        sum(
                            IreFlo[(r, v, t, p, c, ts, "IMP")] *
                            get(data[:RS_FR], (r, s, ts), 0) *
                            (
                                1 + (
                                    !isnothing(data[:RTCS_FR]) ?
                                    get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0
                                )
                            ) for v in get(sets.RTP_VNT, (r, t, p), Set());
                            init = 0,
                        ) for ts in sets.RPC_TS[r, p, c]
                    ) for p in get(sets.RCIE_P, (r, c, "IMP"), Set()) if (r, t, p) in data[:RTP_VARA];
                    init = 0,
                )
            ) * data[:COM_IE][r, t, c, s]
        ) >=
        sum(
            (
                (r, p, c) in data[:RPC_STG] ?
                sum(
                    sum(
                        StgFlo[(r, v, t, p, c, ts, "IN")] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0))
                        for v in get(sets.RTP_VNT, (r, t, p), Set());
                        init = 0,
                    ) for ts in sets.RPC_TS[r, p, c]
                ) :
                (sum(
                    sum(
                        PrcFlo[(r, v, t, p, c, ts)] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0))
                        for v in get(sets.RTP_VNT, (r, t, p), Set());
                        init = 0,
                    ) for ts in sets.RPC_TS[r, p, c]
                ))
            ) for p in get(sets.RCIO_P, (r, c, "IN"), Set()) if (r, t, p) in data[:RTP_VARA];
            init = 0,
        ) +
        sum(
            sum(
                sum(
                    IreFlo[(r, v, t, p, c, ts, "EXP")] *
                    get(data[:RS_FR], (r, s, ts), 0) *
                    (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)) for
                    v in get(sets.RTP_VNT, (r, t, p), Set());
                    init = 0,
                ) for ts in sets.RPC_TS[r, p, c]
            ) for p in get(sets.RCIE_P, (r, c, "EXP"), Set()) if (r, t, p) in data[:RTP_VARA];
            init = 0,
        ) +
        get(data[:COM_PROJ], (r, t, c), 0) * data[:COM_FR][r, t, c, s]
    )

    # %% Commodity Balance - Equal
    JuMP.@constraint(
        model,
        EQE_COMBAL[(r, t, c, s) in indices["EQE_COMBAL"]],
        (
            !isnothing(data[:RHS_COMPRD]) && ((r, t, c, s) in data[:RHS_COMPRD]) ? ComPrd[(r, t, c, s)] :
            (
                sum(
                    (
                        (r, p, c) in data[:RPC_STG] ?
                        sum(
                            sum(
                                StgFlo[(r, v, t, p, c, ts, "OUT")] *
                                get(data[:RS_FR], (r, s, ts), 0) *
                                (
                                    1 + (
                                        !isnothing(data[:RTCS_FR]) ?
                                        get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0
                                    )
                                ) *
                                data[:STG_EFF][r, v, p] for v in get(sets.RTP_VNT, (r, t, p), Set());
                                init = 0,
                            ) for ts in sets.RPC_TS[r, p, c]
                        ) :
                        (sum(
                            sum(
                                PrcFlo[(r, v, t, p, c, ts)] *
                                get(data[:RS_FR], (r, s, ts), 0) *
                                (
                                    1 + (
                                        !isnothing(data[:RTCS_FR]) ?
                                        get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0
                                    )
                                ) for v in get(sets.RTP_VNT, (r, t, p), Set());
                                init = 0,
                            ) for ts in sets.RPC_TS[r, p, c]
                        ))
                    ) for p in get(sets.RCIO_P, (r, c, "OUT"), Set()) if (r, t, p) in data[:RTP_VARA];
                    init = 0,
                ) + sum(
                    sum(
                        sum(
                            IreFlo[(r, v, t, p, c, ts, "IMP")] *
                            get(data[:RS_FR], (r, s, ts), 0) *
                            (
                                1 + (
                                    !isnothing(data[:RTCS_FR]) ?
                                    get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0
                                )
                            ) for v in get(sets.RTP_VNT, (r, t, p), Set());
                            init = 0,
                        ) for ts in sets.RPC_TS[r, p, c]
                    ) for p in get(sets.RCIE_P, (r, c, "IMP"), Set()) if (r, t, p) in data[:RTP_VARA];
                    init = 0,
                )
            ) * data[:COM_IE][r, t, c, s]
        ) ==
        sum(
            (
                (r, p, c) in data[:RPC_STG] ?
                sum(
                    sum(
                        StgFlo[(r, v, t, p, c, ts, "IN")] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0))
                        for v in get(sets.RTP_VNT, (r, t, p), Set());
                        init = 0,
                    ) for ts in sets.RPC_TS[r, p, c]
                ) :
                (sum(
                    sum(
                        PrcFlo[(r, v, t, p, c, ts)] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0))
                        for v in get(sets.RTP_VNT, (r, t, p), Set());
                        init = 0,
                    ) for ts in sets.RPC_TS[r, p, c]
                ))
            ) for p in get(sets.RCIO_P, (r, c, "IN"), Set()) if (r, t, p) in data[:RTP_VARA];
            init = 0,
        ) +
        sum(
            sum(
                sum(
                    IreFlo[(r, v, t, p, c, ts, "EXP")] *
                    get(data[:RS_FR], (r, s, ts), 0) *
                    (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)) for
                    v in get(sets.RTP_VNT, (r, t, p), Set());
                    init = 0,
                ) for ts in sets.RPC_TS[r, p, c]
            ) for p in get(sets.RCIE_P, (r, c, "EXP"), Set()) if (r, t, p) in data[:RTP_VARA];
            init = 0,
        ) +
        ((r, t, c, s) in data[:RHS_COMBAL] ? 1 : 0) * ComNet[(r, t, c, s)] +
        get(data[:COM_PROJ], (r, t, c), 0) * data[:COM_FR][r, t, c, s]
    )

    # %% Commodity Production
    JuMP.@constraint(
        model,
        EQE_COMPRD[(r, t, c, s) in indices["EQE_COMPRD"]],
        sum(
            (
                (r, p, c) in data[:RPC_STG] ?
                sum(
                    sum(
                        StgFlo[(r, v, t, p, c, ts, "OUT")] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (
                            1 +
                            (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0)
                        ) *
                        data[:STG_EFF][r, v, p] for v in sets.RTP_VNT[r, t, p]
                    ) for ts in sets.RPC_TS[r, p, c]
                ) :
                sum(
                    sum(
                        PrcFlo[(r, v, t, p, c, ts)] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0))
                        for v in sets.RTP_VNT[r, t, p]
                    ) for ts in sets.RPC_TS[r, p, c]
                )
            ) + sum(
                sum(
                    sum(
                        IreFlo[(r, v, t, p, c, ts, "IMP")] *
                        get(data[:RS_FR], (r, s, ts), 0) *
                        (1 + (!isnothing(data[:RTCS_FR]) ? get(data[:RTCS_FR], (r, t, c, s, ts), 0) : 0))
                        for v in sets.RTP_VNT[r, t, p]
                    ) for ts in sets.RPC_TS[r, p, c]
                ) for p in sets.RCIE_P[r, c, "IMP"] if (r, t, p) in data[:RTP_VARA]
            ) for p in sets.RCIO_P[r, c, "OUT"] if (r, t, p) in data[:RTP_VARA]
        ) * data[:COM_IE][r, t, c, s] == ComPrd[(r, t, c, s)]
    )

    # %% Timeslice Storage Transformation
    JuMP.@constraint(
        model,
        EQ_STGTSS[(r, v, y, p, s) in indices["EQ_STGTSS"]],
        PrcAct[(r, v, y, p, s)] == sum(
            (
                PrcAct[(r, v, y, p, all_s)] +
                get(data[:STG_CHRG], (r, y, p, all_s), 0) +
                sum(
                    StgFlo[(r, v, y, p, c, all_s, io)] / data[:PRC_ACTFLO][r, v, p, c] *
                    (io == "IN" ? 1 : -1) for
                    (c, io) in sets.RP_CIO[r, p] if (r, p, c) in data[:PRC_STGTSS]
                ) +
                (PrcAct[(r, v, y, p, s)] + PrcAct[(r, v, y, p, all_s)]) / 2 * (
                    (
                        1 - exp(
                            min(
                                0,
                                (
                                    !isnothing(data[:STG_LOSS]) ?
                                    get(data[:STG_LOSS], (r, v, p, all_s), 0) : 0
                                ),
                            ) * data[:G_YRFR][r, all_s] / data[:RS_STGPRD][r, s],
                        )
                    ) +
                    max(
                        0,
                        (!isnothing(data[:STG_LOSS]) ? get(data[:STG_LOSS], (r, v, p, all_s), 0) : 0),
                    ) * data[:G_YRFR][r, all_s] / data[:RS_STGPRD][r, s]
                )
            ) for all_s in data[:TSLICE] if (r, s, all_s) in data[:RS_PRETS]
        )
    )
    return
end
