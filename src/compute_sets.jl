# Requires DataFrames

function compute_sets(data::Dict{String})
    return (;
        LINTY = Dict{Tuple{String,Int16,String},Vector{Int16}}(
            (g.R[1], g.T[1], g.CUR[1]) => g.ALLYEAR for
            g in DataFrames.groupby(data["IS_LINT"], [:R, :T, :CUR])
        ),
        RTP_VNT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
            (g.ALL_REG[1], g.ALLYEAR2[1], g.PRC[1]) => g.ALLYEAR for
            g in DataFrames.groupby(data["RTP_VINTYR"], [:ALL_REG, :ALLYEAR2, :PRC])
        ),
        RTV_PRC = Dict{Tuple{String,Int16,Int16},Vector{String}}(
            (g.ALL_REG[1], g.ALLYEAR2[1], g.ALLYEAR[1]) => g.PRC for
            g in DataFrames.groupby(data["RTP_VINTYR"], [:ALL_REG, :ALLYEAR2, :ALLYEAR])
        ),
        RTP_CPT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
            (g.R[1], g.T[1], g.PRC[1]) => g.ALLYEAR for
            g in DataFrames.groupby(data["RTP_CPTYR"], [:R, :T, :PRC])
        ),
        RTP_AFS = Dict{Tuple{String,Int16,String,String},Vector{String}}(
            (g.R[1], g.T[1], g.P[1], g.BD[1]) => g.S for
            g in DataFrames.groupby(data["AFS"], [:R, :T, :P, :BD])
        ),
        RP_TS = Dict{Tuple{String,String},Vector{String}}(
            (g.ALL_REG[1], g.PRC[1]) => g.ALL_TS for
            g in DataFrames.groupby(data["PRC_TS"], [:ALL_REG, :PRC])
        ),
        RP_S1 = Dict{Tuple{String,String},Vector{String}}(
            (g.R[1], g.P[1]) => g.ALL_TS for g in DataFrames.groupby(data["RPS_S1"], [:R, :P])
        ),
        RP_PGC = Dict{Tuple{String,String},Vector{String}}(
            (g.R[1], g.P[1]) => g.C for g in DataFrames.groupby(data["RPC_PG"], [:R, :P])
        ),
        RP_CIE = Dict{Tuple{String,String},Vector{Tuple{String,String}}}(
            (g.ALL_REG[1], g.P[1]) => Tuple.(eachrow(g[!, [:C, :IE]])) for
            g in DataFrames.groupby(data["RPC_IRE"], [:ALL_REG, :P])
        ),
        RP_CIO = Dict{Tuple{String,String},Vector{Tuple{String,String}}}(
            (g.REG[1], g.PRC[1]) => Tuple.(eachrow(g[!, [:COM, :IO]])) for g in DataFrames.groupby(
                DataFrames.innerjoin(data["TOP"], data["RP_FLO"], on = [:REG => :R, :PRC => :P]),
                [:REG, :PRC],
            )
        ),
        RPC_TS = Dict{Tuple{String,String,String},Vector{String}}(
            (g.R[1], g.P[1], g.C[1]) => g.ALL_TS for
            g in DataFrames.groupby(data["RPCS_VAR"], [:R, :P, :C])
        ),
        RPIO_C = Dict{Tuple{String,String,String},Vector{String}}(
            (g.REG[1], g.PRC[1], g.IO[1]) => g.COM for g in DataFrames.groupby(
                DataFrames.innerjoin(data["TOP"], data["RP_FLO"], on = [:REG => :R, :PRC => :P]),
                [:REG, :PRC, :IO],
            )
        ),
        RCIO_P = Dict{Tuple{String,String,String},Vector{String}}(
            (g.REG[1], g.COM[1], g.IO[1]) => g.PRC for g in DataFrames.groupby(
                DataFrames.innerjoin(data["TOP"], data["RP_FLO"], on = [:REG => :R, :PRC => :P]),
                [:REG, :COM, :IO],
            )
        ),
        RCIE_P = Dict{Tuple{String,String,String},Vector{String}}(
            (g.ALL_REG[1], g.C[1], g.IE[1]) => g.P for
            g in DataFrames.groupby(data["RPC_IRE"], [:ALL_REG, :C, :IE])
        ),
        RP_ACE = if isempty(data["RPC_ACE"])
            nothing
        else
            Dict{Tuple{String,String},Vector{String}}(
                (g.REG[1], g.PRC[1]) => g.CG for g in DataFrames.groupby(data["RPC_ACE"], [:REG, :PRC])
            )
        end,
        R_P = Dict{String,Vector{String}}(g.R[1] => g.P for g in DataFrames.groupby(data["RP"], :R)),
        R_C = Dict{String,Vector{String}}(g.R[1] => g.C for g in DataFrames.groupby(data["RC"], :R)),
        RP_C = Dict{Tuple{String,String},Vector{String}}(
            (g.R[1], g.P[1]) => g.C for g in DataFrames.groupby(data["RPC"], [:R, :P])
        ),
        R_CPT = Dict{String,Vector{Tuple{Int16,Int16,String}}}(
            g.R[1] => Tuple.(eachrow(g[!, [:ALLYEAR, :T, :PRC]])) for
            g in DataFrames.groupby(data["RTP_CPTYR"], :R)
        ),
    )
end
