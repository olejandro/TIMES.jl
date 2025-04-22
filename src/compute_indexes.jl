# Requires DataFrames

function compute_indexes(data)
    # Create intermediate dataframes
    EQs_CAPACT = DataFrames.innerjoin(
        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DataFrames.rename(data["AFS"], [:r, :t, :p, :s, :bd]),
        on = [:r, :t, :p],
    )

    EQs_FLOSHR = DataFrames.innerjoin(
        DataFrames.innerjoin(
            DataFrames.rename(data["FLO_SHAR"][:, DataFrames.Not(:value)], [:r, :v, :p, :c, :cg, :s, :bd]),
            DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
            on = [:r, :p],
        ),
        DataFrames.innerjoin(
            DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
            DataFrames.rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
            on = [:r, :p],
        ),
        on = [:r, :v, :p, :c, :s, :t],
    )

    vars_base = DataFrames.innerjoin(
        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
        on = [:r, :t, :p],
    )

    # Create indices
    indices = Dict{String,Set{Tuple}}()

    # Equations and expressions
    indices["EQ_ACTFLO"] = Set(
        Tuple.(
            eachrow(
                DataFrames.innerjoin(
                    DataFrames.innerjoin(
                        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                        DataFrames.rename(data["PRC_TS"], [:r, :p, :s]),
                        on = [:r, :p],
                    ),
                    DataFrames.rename(data["PRC_ACT"], [:r, :p]),
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
                DataFrames.innerjoin(
                    DataFrames.innerjoin(
                        DataFrames.rename(data["RPG_ACE"], [:r, :p, :cg, :io]),
                        DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
                        on = [:r, :p],
                    ),
                    DataFrames.innerjoin(
                        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                        DataFrames.rename(data["RPS_S1"], [:r, :p, :s]),
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
                DataFrames.innerjoin(
                    DataFrames.innerjoin(
                        DataFrames.innerjoin(
                            DataFrames.rename(data["RP_PTRAN"], [:r, :p, :cg1, :cg2, :s1]),
                            DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
                            on = [:r, :p],
                        ),
                        DataFrames.innerjoin(
                            DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                            DataFrames.rename(data["RPS_S1"], [:r, :p, :s]),
                            on = [:r, :p],
                        ),
                        on = [:r, :p, :t],
                    ),
                    DataFrames.rename(data["RS_FR"][:, DataFrames.Not(:value)], [:r, :s1, :s]),
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
                    DataFrames.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    DataFrames.Not(:bd),
                ],
            )
        ),
    )
    indices["EQE_COMBAL"] = Set(
        Tuple.(
            eachrow(
                filter(
                    :bd => f -> f == "FX",
                    DataFrames.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    DataFrames.Not(:bd),
                ],
            )
        ),
    )

    indices["EQE_COMPRD"] = Set(
        Tuple.(
            eachrow(
                filter(
                    :bd => f -> f == "FX",
                    DataFrames.rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    DataFrames.Not(:bd),
                ],
            )
        ),
    )

    indices["EQ_STGTSS"] = Set(
        Tuple.(
            eachrow(
                DataFrames.innerjoin(
                    DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                    DataFrames.rename(data["RPS_STG"], [:r, :p, :s]),
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
                    DataFrames.rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
                    DataFrames.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
                )[
                    :,
                    [:r, :t, :c, :s],
                ],
            )
        ),
    )
    indices["var_ComNet"] = indices["var_ComPrd"]
    indices["var_PrcCap"] =
        Set(Tuple.(eachrow(DataFrames.rename(data["RTP"], [:r, :y, :p])[:, [:r, :y, :p]])))
    indices["var_PrcNcap"] = indices["var_PrcCap"]
    indices["var_PrcAct"] = Set(
        Tuple.(
            eachrow(
                DataFrames.innerjoin(vars_base, DataFrames.rename(data["PRC_TS"], [:r, :p, :s]), on = [:r, :p]),
            )
        ),
    )
    indices["var_PrcFlo"] = Set(
        Tuple.(
            eachrow(
                DataFrames.innerjoin(
                    vars_base,
                    DataFrames.innerjoin(
                        DataFrames.rename(data["RP_FLO"], [:r, :p]),
                        DataFrames.rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
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
                DataFrames.innerjoin(
                    DataFrames.innerjoin(vars_base, DataFrames.rename(data["RP_IRE"], [:r, :p]), on = [:r, :p]),
                    DataFrames.innerjoin(
                        DataFrames.rename(data["RPC_IRE"], [:r, :p, :c, :ie]),
                        DataFrames.rename(data["PRC_TS"], [:r, :p, :s]),
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
                DataFrames.innerjoin(
                    DataFrames.innerjoin(vars_base, DataFrames.rename(data["RP_STG"], [:r, :p]), on = [:r, :p]),
                    DataFrames.innerjoin(
                        DataFrames.rename(data["TOP"], [:r, :p, :c, :io]),
                        DataFrames.rename(data["PRC_TS"], [:r, :p, :s]),
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
