# Requires DataFrames

function compute_sets(data)

    global LINTY = Dict{Tuple{String,Int16,String},Vector{Int16}}(
        (g.R[1], g.T[1], g.CUR[1]) => g.ALLYEAR for
        g in groupby(data["IS_LINT"], [:R, :T, :CUR])
    )

    global RTP_VNT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
        (g.ALL_REG[1], g.ALLYEAR2[1], g.PRC[1]) => g.ALLYEAR for
        g in groupby(data["RTP_VINTYR"], [:ALL_REG, :ALLYEAR2, :PRC])
    )

    global RTV_PRC = Dict{Tuple{String,Int16,Int16},Vector{String}}(
        (g.ALL_REG[1], g.ALLYEAR2[1], g.ALLYEAR[1]) => g.PRC for
        g in groupby(data["RTP_VINTYR"], [:ALL_REG, :ALLYEAR2, :ALLYEAR])
    )

    global RTP_CPT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
        (g.R[1], g.T[1], g.PRC[1]) => g.ALLYEAR for
        g in groupby(data["RTP_CPTYR"], [:R, :T, :PRC])
    )

    global RTP_AFS = Dict{Tuple{String,Int16,String,String},Vector{String}}(
        (g.R[1], g.T[1], g.P[1], g.BD[1]) => g.S for
        g in groupby(data["AFS"], [:R, :T, :P, :BD])
    )

    global RP_TS = Dict{Tuple{String,String},Vector{String}}(
        (g.ALL_REG[1], g.PRC[1]) => g.ALL_TS for
        g in groupby(data["PRC_TS"], [:ALL_REG, :PRC])
    )

    global RP_S1 = Dict{Tuple{String,String},Vector{String}}(
        (g.R[1], g.P[1]) => g.ALL_TS for g in groupby(data["RPS_S1"], [:R, :P])
    )

    global RP_PGC = Dict{Tuple{String,String},Vector{String}}(
        (g.R[1], g.P[1]) => g.C for g in groupby(data["RPC_PG"], [:R, :P])
    )

    global RP_CIE = Dict{Tuple{String,String},Vector{Tuple{String,String}}}(
        (g.ALL_REG[1], g.P[1]) => Tuple.(eachrow(g[!, [:C, :IE]])) for
        g in groupby(data["RPC_IRE"], [:ALL_REG, :P])
    )

    global RP_CIO = Dict{Tuple{String,String},Vector{Tuple{String,String}}}(
        (g.REG[1], g.PRC[1]) => Tuple.(eachrow(g[!, [:COM, :IO]])) for g in groupby(
            innerjoin(data["TOP"], data["RP_FLO"], on = [:REG => :R, :PRC => :P]),
            [:REG, :PRC],
        )
    )

    global RPC_TS = Dict{Tuple{String,String,String},Vector{String}}(
        (g.R[1], g.P[1], g.C[1]) => g.ALL_TS for
        g in groupby(data["RPCS_VAR"], [:R, :P, :C])
    )

    global RPIO_C = Dict{Tuple{String,String,String},Vector{String}}(
        (g.REG[1], g.PRC[1], g.IO[1]) => g.COM for g in groupby(
            innerjoin(data["TOP"], data["RP_FLO"], on = [:REG => :R, :PRC => :P]),
            [:REG, :PRC, :IO],
        )
    )

    global RCIO_P = Dict{Tuple{String,String,String},Vector{String}}(
        (g.REG[1], g.COM[1], g.IO[1]) => g.PRC for g in groupby(
            innerjoin(data["TOP"], data["RP_FLO"], on = [:REG => :R, :PRC => :P]),
            [:REG, :COM, :IO],
        )
    )

    global RCIE_P = Dict{Tuple{String,String,String},Vector{String}}(
        (g.ALL_REG[1], g.C[1], g.IE[1]) => g.P for
        g in groupby(data["RPC_IRE"], [:ALL_REG, :C, :IE])
    )

    global RP_ACE =
        !isnothing(RPC_ACE) ?
        Dict{Tuple{String,String},Vector{String}}(
            (g.REG[1], g.PRC[1]) => g.CG for g in groupby(data["RPC_ACE"], [:REG, :PRC])
        ) : nothing

    global R_P = Dict{String,Vector{String}}(g.R[1] => g.P for g in groupby(data["RP"], :R))

    global R_C = Dict{String,Vector{String}}(g.R[1] => g.C for g in groupby(data["RC"], :R))

    global RP_C = Dict{Tuple{String,String},Vector{String}}(
        (g.R[1], g.P[1]) => g.C for g in groupby(data["RPC"], [:R, :P])
    )

    global R_CPT = Dict{String,Vector{Tuple{Int16,Int16,String}}}(
        g.R[1] => Tuple.(eachrow(g[!, [:ALLYEAR, :T, :PRC]])) for
        g in groupby(data["RTP_CPTYR"], :R)
    )

end
