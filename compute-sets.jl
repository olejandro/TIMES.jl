LINTY = Dict{Tuple{String,Int16,String},Vector{Int16}}(
    (r, t, cur) => [y for y in MODLYR if (r, t, y, cur) in IS_LINT] for
    (r, t, y, cur) in IS_LINT
)

RTP_VNT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
    (r, t, p) => [y for y in MODLYR if (r, y, t, p) in RTP_VINTYR] for
    (r, y, t, p) in RTP_VINTYR
)

RTP_CPT = Dict{Tuple{String,Int16,String},Vector{Int16}}(
    (r, t, p) => [y for y in MODLYR if (r, y, t, p) in RTP_CPTYR] for
    (r, y, t, p) in RTP_CPTYR
)

RTP_AFS = Dict{Tuple{String,Int16,String,String},Vector{String}}(
    (r, t, p, l) => [s for s in TSLICE if (r, t, p, s, l) in AFS] for
    (r, t, p, s, l) in AFS
)

RP_TS = Dict{Tuple{String,String},Vector{String}}(
    (r, p) => [s for s in TSLICE if (r, p, s) in PRC_TS] for (r, p, s) in PRC_TS
)

RP_S1 = Dict{Tuple{String,String},Vector{String}}(
    (r, p) => [s for s in TSLICE if (r, p, s) in RPS_S1] for (r, p, s) in RPS_S1
)

RP_PGC = Dict{Tuple{String,String},Vector{String}}(
    (r, p) => [c for c in COMMTY if (r, p, c) in RPC_PG] for (r, p, c) in RPC_PG
)

RP_CIE = Dict{Tuple{String,String},Vector{Tuple{String,String}}}(
    (r, p) => [(c, ie) for c in COMMTY for ie in IMPEXP if (r, p, c, ie) in RPC_IRE] for
    (r, p, c, ie) in RPC_IRE
)

RPC_TS = Dict{Tuple{String,String,String},Vector{String}}(
    (r, p, c) => [s for s in TSLICE if (r, p, c, s) in RPCS_VAR] for
    (r, p, c, s) in RPCS_VAR
)

RPIO_C = Dict{Tuple{String,String,String},Vector{String}}(
    (r, p, io) => [c for c in COMMTY if (r, p, c, io) in TOP] for (r, p, c, io) in TOP
)

RCIO_P = Dict{Tuple{String,String,String},Vector{String}}(
    (r, c, io) => [p for p in PROCESS if (r, p, c, io) in TOP] for (r, p, c, io) in TOP
)

RCIE_P = Dict{Tuple{String,String,String},Vector{String}}(
    (r, c, ie) => [p for p in PROCESS if (r, p, c, ie) in RPC_IRE] for
    (r, p, c, ie) in RPC_IRE
)

RP_ACE =
    !isnothing(RPC_ACE) ?
    Dict{Tuple{String,String},Vector{String}}(
        (r, p) => [c for c in COMMTY if (r, p, c) in RPC_ACE] for (r, p, c) in RPC_ACE
    ) : nothing

R_P =
    Dict{String,Vector{String}}(r => [p for p in PROCESS if (r, p) in RP] for (r, p) in RP)

R_C = Dict{String,Vector{String}}(r => [c for c in COMMTY if (r, c) in RC] for (r, c) in RC)

RP_C = Dict{Tuple{String,String},Vector{String}}(
    (r, p) => [c for c in COMMTY if (r, p, c) in RPC] for (r, p, c) in RPC
)
