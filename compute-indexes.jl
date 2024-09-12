using DataFrames;

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

# Create filters
filters = Dict{String,Set{Tuple}}()

filters["EQ_ACTFLO"] = Set(
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

filters["EQL_CAPACT"] =
    Set(Tuple.(eachrow(filter(:bd => f -> f == "UP", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])))
filters["EQE_CAPACT"] =
    Set(Tuple.(eachrow(filter(:bd => f -> f == "FX", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]])))

filters["EXPR_FLOSHR"] = Set(Tuple.(eachrow(EQs_FLOSHR)))
filters["EQL_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "LO", EQs_FLOSHR))))
filters["EQG_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "UP", EQs_FLOSHR))))
filters["EQE_FLOSHR"] = Set(Tuple.(eachrow(filter(:bd => f -> f == "FX", EQs_FLOSHR))))

filters["EQE_ACTEFF"] = Set(
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

filters["EQ_PTRANS"] = Set(
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

filters["EQG_COMBAL"] = Set(
    Tuple.(
        eachrow(
            filter(:bd => f -> f == "LO", rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]))[
                :,
                Not(:bd),
            ],
        )
    ),
)
filters["EQE_COMBAL"] = Set(
    Tuple.(
        eachrow(
            filter(:bd => f -> f == "FX", rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]))[
                :,
                Not(:bd),
            ],
        )
    ),
)

filters["EQE_COMPRD"] = Set(
    Tuple.(
        eachrow(
            filter(:bd => f -> f == "FX", rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]))[
                :,
                Not(:bd),
            ],
        )
    ),
)

filters["EQ_STGTSS"] = Set(
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


filters["var_PrcAct"] = Set(
    Tuple.(
        eachrow(innerjoin(vars_base, rename(data["PRC_TS"], [:r, :p, :s]), on = [:r, :p]))
    ),
)
filters["var_PrcFlo"] = Set(
    Tuple.(eachrow(innerjoin(vars_base, rename(data["RP_FLO"], [:r, :p]), on = [:r, :p]))),
)
filters["var_IreFlo"] = Set(
    Tuple.(
        eachrow(
            innerjoin(
                innerjoin(vars_base, rename(data["RP_IRE"], [:r, :p]), on = [:r, :p]),
                rename(data["RPC_IRE"], [:r, :p, :c, :ie]),
                on = [:r, :p],
            ),
        )
    ),
)
filters["var_StgFlo"] = Set(
    Tuple.(
        eachrow(
            innerjoin(
                innerjoin(vars_base, rename(data["RP_STG"], [:r, :p]), on = [:r, :p]),
                rename(data["TOP"], [:r, :p, :c, :io]),
                on = [:r, :p],
            ),
        )
    ),
)

