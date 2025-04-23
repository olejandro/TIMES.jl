# Requires DataFrames

function compute_indexes(data)
    # Create intermediate dataframes
    EQs_CAPACT = DF.innerjoin(
        DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DF.rename(data["AFS"], [:r, :t, :p, :s, :bd]),
        on = [:r, :t, :p],
    )

    EQs_FLOSHR = DF.innerjoin(
        DF.innerjoin(
            DF.rename(data["FLO_SHAR"][:, DF.Not(:value)], [:r, :v, :p, :c, :cg, :s, :bd]),
            DF.rename(data["RTP_VARA"], [:r, :t, :p]),
            on = [:r, :p],
        ),
        DF.innerjoin(
            DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
            DF.rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
            on = [:r, :p],
        ),
        on = [:r, :v, :p, :c, :s, :t],
    )

    vars_base = DF.innerjoin(
        DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DF.rename(data["RTP_VARA"], [:r, :t, :p]),
        on = [:r, :t, :p],
    )

    # Create indices
    indices = Dict{String,Set{Tuple}}()

    # Equations and expressions
    indices["EQ_ACTFLO"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    DF.innerjoin(
                        DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                        DF.rename(data["PRC_TS"], [:r, :p, :s]),
                        on = [:r, :p],
                    ),
                    DF.rename(data["PRC_ACT"], [:r, :p]),
                    on = [:r, :p],
                ),
            )
        ),
    )

    indices["EQG_CAPACT"] = Set(
        Tuple.(eachrow(filter(:bd => f -> f == "LO", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])),
    )
    indices["EQL_CAPACT"] = Set(
        Tuple.(eachrow(filter(:bd => f -> f == "UP", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])),
    )
    indices["EQE_CAPACT"] = Set(
        Tuple.(eachrow(filter(:bd => f -> f == "FX", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])),
    )

    indices["EXPR_FLOSHR"] = Set(Tuple.(eachrow(EQs_FLOSHR)))
    indices["EQL_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "LO", EQs_FLOSHR))))
    indices["EQG_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "UP", EQs_FLOSHR))))
    indices["EQE_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "FX", EQs_FLOSHR))))

    indices["EQE_ACTEFF"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    DF.innerjoin(
                        DF.rename(data["RPG_ACE"], [:r, :p, :cg, :io]),
                        DF.rename(data["RTP_VARA"], [:r, :t, :p]),
                        on = [:r, :p],
                    ),
                    DF.innerjoin(
                        DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                        DF.rename(data["RPS_S1"], [:r, :p, :s]),
                        on = [:r, :p],
                    ),
                    on = [:r, :p, :t],
                ),
            )
        ),
    )

    indices["EQ_PTRANS"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    DF.innerjoin(
                        DF.innerjoin(
                            DF.rename(data["RP_PTRAN"], [:r, :p, :cg1, :cg2, :s1]),
                            DF.rename(data["RTP_VARA"], [:r, :t, :p]),
                            on = [:r, :p],
                        ),
                        DF.innerjoin(
                            DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                            DF.rename(data["RPS_S1"], [:r, :p, :s]),
                            on = [:r, :p],
                        ),
                        on = [:r, :p, :t],
                    ),
                    DF.rename(data["RS_FR"][:, DF.Not(:value)], [:r, :s1, :s]),
                    on = [:r, :s1, :s],
                ),
            )
        ),
    )

    indices["EQG_COMBAL"] = Set(
        Tuple.(
            eachrow(
                filter(
                    :bd => f -> f == "LO",
                    DF.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    DF.Not(:bd),
                ],
            )
        ),
    )
    indices["EQE_COMBAL"] = Set(
        Tuple.(
            eachrow(
                filter(
                    :bd => f -> f == "FX",
                    DF.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    DF.Not(:bd),
                ],
            )
        ),
    )

    indices["EQE_COMPRD"] = Set(
        Tuple.(
            eachrow(
                filter(
                    :bd => f -> f == "FX",
                    DF.rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    DF.Not(:bd),
                ],
            )
        ),
    )

    indices["EQ_STGTSS"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    DF.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                    DF.rename(data["RPS_STG"], [:r, :p, :s]),
                    on = [:r, :p],
                ),
            )
        ),
    )

    # Variables
    indices["var_ComPrd"] = Set(
        Tuple.(
            eachrow(
                vcat(
                    DF.rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
                    DF.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    [:r, :t, :c, :s],
                ],
            )
        ),
    )
    indices["var_ComNet"] = indices["var_ComPrd"]
    indices["var_PrcCap"] =
        Set(Tuple.(eachrow(DF.rename(data["RTP"], [:r, :y, :p])[:, [:r, :y, :p]])))
    indices["var_PrcNcap"] = indices["var_PrcCap"]
    indices["var_PrcAct"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(vars_base, DF.rename(data["PRC_TS"], [:r, :p, :s]), on = [:r, :p]),
            )
        ),
    )
    indices["var_PrcFlo"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    vars_base,
                    DF.innerjoin(
                        DF.rename(data["RP_FLO"], [:r, :p]),
                        DF.rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
                        on = [:r, :p],
                    ),
                    on = [:r, :p],
                ),
            )
        ),
    )
    indices["var_IreFlo"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    DF.innerjoin(vars_base, DF.rename(data["RP_IRE"], [:r, :p]), on = [:r, :p]),
                    DF.innerjoin(
                        DF.rename(data["RPC_IRE"], [:r, :p, :c, :ie]),
                        DF.rename(data["PRC_TS"], [:r, :p, :s]),
                        on = [:r, :p],
                    )[
                        :,
                        [:r, :p, :c, :s, :ie],
                    ],
                    on = [:r, :p],
                ),
            )
        ),
    )
    indices["var_StgFlo"] = Set(
        Tuple.(
            eachrow(
                DF.innerjoin(
                    DF.innerjoin(vars_base, DF.rename(data["RP_STG"], [:r, :p]), on = [:r, :p]),
                    DF.innerjoin(
                        DF.rename(data["TOP"], [:r, :p, :c, :io]),
                        DF.rename(data["PRC_TS"], [:r, :p, :s]),
                        on = [:r, :p],
                    )[
                        :,
                        [:r, :p, :c, :s, :io],
                    ],
                    on = [:r, :p],
                ),
            )
        ),
    )
    return indices
end
