# Requires DataFrames

# Create intermediate dataframes
EQs_CAPACT = innerjoin(
    rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
    rename(data["AFS"], [:r, :t, :p, :s, :bd]),
    on = [:r, :t, :p],
)

EQs_FLOSHR = innerjoin(
    innerjoin(
        rename(data["FLO_SHAR"][:, Not(:value)], [:r, :v, :p, :c, :cg, :s, :bd]),
        rename(data["RTP_VARA"], [:r, :t, :p]),
        on = [:r, :p],
    ),
    innerjoin(
        rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
        on = [:r, :p],
    ),
    on = [:r, :v, :p, :c, :s, :t],
)

vars_base = innerjoin(
    rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
    rename(data["RTP_VARA"], [:r, :t, :p]),
    on = [:r, :t, :p],
)

# Create indices
indices = Dict{String,Set{Tuple}}()

# Equations and expressions
indices["EQ_ACTFLO"] = Set(
    Tuple.(
        eachrow(
            innerjoin(
                innerjoin(
                    rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                    rename(data["PRC_TS"], [:r, :p, :s]),
                    on = [:r, :p],
                ),
                rename(data["PRC_ACT"], [:r, :p]),
                on = [:r, :p],
            ),
        )
    ),
)

indices["EQG_CAPACT"] =
    Set(Tuple.(eachrow(filter(:bd => f -> f == "LO", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])))
indices["EQL_CAPACT"] =
    Set(Tuple.(eachrow(filter(:bd => f -> f == "UP", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])))
indices["EQE_CAPACT"] =
    Set(Tuple.(eachrow(filter(:bd => f -> f == "FX", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])))

indices["EXPR_FLOSHR"] = Set(Tuple.(eachrow(EQs_FLOSHR)))
indices["EQL_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "LO", EQs_FLOSHR))))
indices["EQG_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "UP", EQs_FLOSHR))))
indices["EQE_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "FX", EQs_FLOSHR))))

indices["EQE_ACTEFF"] = Set(
    Tuple.(
        eachrow(
            innerjoin(
                innerjoin(
                    rename(data["RPG_ACE"], [:r, :p, :cg, :io]),
                    rename(data["RTP_VARA"], [:r, :t, :p]),
                    on = [:r, :p],
                ),
                innerjoin(
                    rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                    rename(data["RPS_S1"], [:r, :p, :s]),
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
            innerjoin(
                innerjoin(
                    innerjoin(
                        rename(data["RP_PTRAN"], [:r, :p, :cg1, :cg2, :s1]),
                        rename(data["RTP_VARA"], [:r, :t, :p]),
                        on = [:r, :p],
                    ),
                    innerjoin(
                        rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                        rename(data["RPS_S1"], [:r, :p, :s]),
                        on = [:r, :p],
                    ),
                    on = [:r, :p, :t],
                ),
                rename(data["RS_FR"][:, Not(:value)], [:r, :s1, :s]),
                on = [:r, :s1, :s],
            ),
        )
    ),
)

indices["EQG_COMBAL"] = Set(
    Tuple.(
        eachrow(
            filter(:bd => f -> f == "LO", rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]))[
                :,
                Not(:bd),
            ],
        )
    ),
)
indices["EQE_COMBAL"] = Set(
    Tuple.(
        eachrow(
            filter(:bd => f -> f == "FX", rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]))[
                :,
                Not(:bd),
            ],
        )
    ),
)

indices["EQE_COMPRD"] = Set(
    Tuple.(
        eachrow(
            filter(:bd => f -> f == "FX", rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]))[
                :,
                Not(:bd),
            ],
        )
    ),
)

indices["EQ_STGTSS"] = Set(
    Tuple.(
        eachrow(
            innerjoin(
                rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                rename(data["RPS_STG"], [:r, :p, :s]),
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
                rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
                rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
            )[
                :,
                [:r, :t, :c, :s],
            ],
        )
    ),
)
indices["var_ComNet"] = indices["var_ComPrd"]
indices["var_PrcCap"] =
    Set(Tuple.(eachrow(rename(data["RTP"], [:r, :y, :p])[:, [:r, :y, :p]])))
indices["var_PrcNcap"] = indices["var_PrcCap"]
indices["var_PrcAct"] = Set(
    Tuple.(
        eachrow(innerjoin(vars_base, rename(data["PRC_TS"], [:r, :p, :s]), on = [:r, :p]))
    ),
)
indices["var_PrcFlo"] = Set(
    Tuple.(
        eachrow(
            innerjoin(
                vars_base,
                innerjoin(
                    rename(data["RP_FLO"], [:r, :p]),
                    rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
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
            innerjoin(
                innerjoin(vars_base, rename(data["RP_IRE"], [:r, :p]), on = [:r, :p]),
                innerjoin(
                    rename(data["RPC_IRE"], [:r, :p, :c, :ie]),
                    rename(data["PRC_TS"], [:r, :p, :s]),
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
            innerjoin(
                innerjoin(vars_base, rename(data["RP_STG"], [:r, :p]), on = [:r, :p]),
                innerjoin(
                    rename(data["TOP"], [:r, :p, :c, :io]),
                    rename(data["PRC_TS"], [:r, :p, :s]),
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

