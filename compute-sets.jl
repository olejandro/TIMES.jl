using DataFrames;

LINTY = Dict{Tuple{String,Int16,String},Vector{Int16}}(
    (g.R[1], g.T[1], g.CUR[1]) => g.ALLYEAR for
    g in groupby(data["IS_LINT"], [:R, :T, :CUR])
)

RTP_VNT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
    (g.REG[1], g.ALLYEAR2[1], g.PRC[1]) => g.ALLYEAR for
    g in groupby(data["RTP_VINTYR"], [:REG, :ALLYEAR2, :PRC])
)

RTP_CPT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
    (g.R[1], g.T[1], g.PRC[1]) => g.ALLYEAR for
    g in groupby(data["RTP_CPTYR"], [:R, :T, :PRC])
)

RTP_AFS = Dict{Tuple{String,Int16,String,String},Vector{String}}(
    (g.R[1], g.T[1], g.P[1], g.BD[1]) => g.S for
    g in groupby(data["AFS"], [:R, :T, :P, :BD])
)

RP_TS = Dict{Tuple{String,String},Vector{String}}(
    (g.ALL_REG[1], g.PRC[1]) => g.ALL_TS for g in groupby(data["PRC_TS"], [:ALL_REG, :PRC])
)

RP_S1 = Dict{Tuple{String,String},Vector{String}}(
    (g.R[1], g.P[1]) => g.ALL_TS for g in groupby(data["RPS_S1"], [:R, :P])
)

RP_PGC = Dict{Tuple{String,String},Vector{String}}(
    (g.R[1], g.P[1]) => g.C for g in groupby(data["RPC_PG"], [:R, :P])
)

RP_CIE = Dict{Tuple{String,String},Vector{Tuple{String,String}}}(
    (g.ALL_REG[1], g.P[1]) => Tuple.(eachrow(g[!, [:C, :IE]])) for
    g in groupby(data["RPC_IRE"], [:ALL_REG, :P])
)

RPC_TS = Dict{Tuple{String,String,String},Vector{String}}(
    (g.R[1], g.P[1], g.C[1]) => g.ALL_TS for g in groupby(data["RPCS_VAR"], [:R, :P, :C])
)

RPIO_C = Dict{Tuple{String,String,String},Vector{String}}(
    (g.REG[1], g.PRC[1], g.IO[1]) => g.COM for g in groupby(data["TOP"], [:REG, :PRC, :IO])
)

RCIO_P = Dict{Tuple{String,String,String},Vector{String}}(
    (g.REG[1], g.COM[1], g.IO[1]) => g.PRC for g in groupby(data["TOP"], [:REG, :COM, :IO])
)

RCIE_P = Dict{Tuple{String,String,String},Vector{String}}(
    (g.ALL_REG[1], g.C[1], g.IE[1]) => g.P for
    g in groupby(data["RPC_IRE"], [:ALL_REG, :C, :IE])
)

RP_ACE =
    !isnothing(RPC_ACE) ?
    Dict{Tuple{String,String},Vector{String}}(
        (g.REG[1], g.PRC[1]) => g.CG for g in groupby(data["RPC_ACE"], [:REG, :PRC])
    ) : nothing

R_P = Dict{String,Vector{String}}(g.R[1] => g.P for g in groupby(data["RP"], :R))

R_C = Dict{String,Vector{String}}(g.R[1] => g.C for g in groupby(data["RC"], :R))

RP_C = Dict{Tuple{String,String},Vector{String}}(
    (g.R[1], g.P[1]) => g.C for g in groupby(data["RPC"], [:R, :P])
)
