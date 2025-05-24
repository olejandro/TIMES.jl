# Requires DataFrames

function compute_indexes(data)
    # Create intermediate dataframes
    EQs_CAPACT = DataFrames.innerjoin(
        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DataFrames.rename(data["AFS"], [:r, :t, :p, :s, :bd]),
        on=[:r, :t, :p],
    )

    EQs_FLOSHR = DataFrames.innerjoin(
        DataFrames.innerjoin(
            DataFrames.rename(data["FLO_SHAR"][:, DataFrames.Not(:value)], [:r, :v, :p, :c, :cg, :s, :bd]),
            DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
            on=[:r, :p],
        ),
        DataFrames.innerjoin(
            DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
            DataFrames.rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
            on=[:r, :p],
        ),
        on=[:r, :v, :p, :c, :s, :t],
    )

    vars_base = DataFrames.innerjoin(
        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
        on=[:r, :t, :p],
    )

    # Create indices
    indices = Dict{String,DataFrames.DataFrame}()

    # Equations and expressions
    indices["EQ_ACTFLO"] =
        DataFrames.innerjoin(
            DataFrames.innerjoin(
                DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                DataFrames.rename(data["PRC_TS"], [:r, :p, :s]),
                on=[:r, :p],
            ),
            DataFrames.rename(data["PRC_ACT"], [:r, :p]),
            on=[:r, :p],
        )

    indices["EQG_CAPACT"] = filter(:bd => f -> f == "LO", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]]
    indices["EQL_CAPACT"] = filter(:bd => f -> f == "UP", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]]
    indices["EQE_CAPACT"] = filter(:bd => f -> f == "FX", EQs_CAPACT)[!, [:r, :v, :t, :p, :s]]

    indices["EXPR_FLOSHR"] = EQs_FLOSHR
    indices["EQL_FLOSHR"] = filter(:bd => f -> f == "LO", EQs_FLOSHR)
    indices["EQG_FLOSHR"] = filter(:bd => f -> f == "UP", EQs_FLOSHR)
    indices["EQE_FLOSHR"] = filter(:bd => f -> f == "FX", EQs_FLOSHR)

    indices["EQE_ACTEFF"] = DataFrames.innerjoin(
        DataFrames.innerjoin(
            DataFrames.rename(data["RPG_ACE"], [:r, :p, :cg, :io]),
            DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
            on=[:r, :p],
        ),
        DataFrames.innerjoin(
            DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
            DataFrames.rename(data["RPS_S1"], [:r, :p, :s]),
            on=[:r, :p],
        ),
        on=[:r, :p, :t],
    )

    indices["EQ_PTRANS"] = DataFrames.innerjoin(
        DataFrames.innerjoin(
            DataFrames.innerjoin(
                DataFrames.rename(data["RP_PTRAN"], [:r, :p, :cg1, :cg2, :s1]),
                DataFrames.rename(data["RTP_VARA"], [:r, :t, :p]),
                on=[:r, :p],
            ),
            DataFrames.innerjoin(
                DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
                DataFrames.rename(data["RPS_S1"], [:r, :p, :s]),
                on=[:r, :p],
            ),
            on=[:r, :p, :t],
        ),
        DataFrames.rename(data["RS_FR"][:, DataFrames.Not(:value)], [:r, :s1, :s]),
        on=[:r, :s1, :s],
    )

    indices["EQG_COMBAL"] = filter(
        :bd => f -> f == "LO",
        DataFrames.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
    )[
        :,
        DataFrames.Not(:bd),
    ]

    indices["EQE_COMBAL"] = filter(
        :bd => f -> f == "FX",
        DataFrames.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
    )[
        :,
        DataFrames.Not(:bd),
    ]

    indices["EQE_COMPRD"] = filter(
        :bd => f -> f == "FX",
        DataFrames.rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
    )[
        :,
        DataFrames.Not(:bd),
    ]

    indices["EQ_STGTSS"] = DataFrames.innerjoin(
        DataFrames.rename(data["RTP_VINTYR"], [:r, :v, :t, :p]),
        DataFrames.rename(data["RPS_STG"], [:r, :p, :s]),
        on=[:r, :p],
    )

    # Variables
    indices["var_ComPrd"] = vcat(
        DataFrames.rename(data["RCS_COMPRD"], [:r, :t, :c, :s, :bd]),
        DataFrames.rename(data["RCS_COMBAL"], [:r, :t, :c, :s, :bd]),
    )[
        :,
        [:r, :t, :c, :s],
    ]
    indices["var_PrcCap"] = DataFrames.rename(data["RTP"], [:r, :y, :p])[:, [:r, :y, :p]]
    indices["var_PrcAct"] = DataFrames.innerjoin(vars_base, DataFrames.rename(data["PRC_TS"], [:r, :p, :s]), on=[:r, :p])
    indices["var_PrcFlo"] = DataFrames.innerjoin(
        vars_base,
        DataFrames.innerjoin(
            DataFrames.rename(data["RP_FLO"], [:r, :p]),
            DataFrames.rename(data["RPCS_VAR"], [:r, :p, :c, :s]),
            on=[:r, :p],
        ),
        on=[:r, :p],
    )
    indices["var_IreFlo"] = DataFrames.innerjoin(
        DataFrames.innerjoin(vars_base, DataFrames.rename(data["RP_IRE"], [:r, :p]), on=[:r, :p]),
        DataFrames.innerjoin(
            DataFrames.rename(data["RPC_IRE"], [:r, :p, :c, :ie]),
            DataFrames.rename(data["PRC_TS"], [:r, :p, :s]),
            on=[:r, :p],
        )[
            :,
            [:r, :p, :c, :s, :ie],
        ],
        on=[:r, :p],
    )
    indices["var_StgFlo"] = DataFrames.innerjoin(
        DataFrames.innerjoin(vars_base, DataFrames.rename(data["RP_STG"], [:r, :p]), on=[:r, :p]),
        DataFrames.innerjoin(
            DataFrames.rename(data["TOP"], [:r, :p, :c, :io]),
            DataFrames.rename(data["PRC_TS"], [:r, :p, :s]),
            on=[:r, :p],
        )[
            :,
            [:r, :p, :c, :s, :io],
        ],
        on=[:r, :p],
    )

    # Convert dataframes to vectors of unique tuples
    result = Dict{String,Vector{Tuple}}(
        key => Tuple.(eachrow(unique(indices[key]))) for key in keys(indices)
    )

    result["var_ComNet"] = result["var_ComPrd"]
    result["var_PrcNcap"] = result["var_PrcCap"]

    return result
end
