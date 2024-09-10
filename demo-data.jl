using SQLite;
using DataFrames;
using JuMP;
using OrderedCollections: OrderedDict;

db = SQLite.DB("PROTO.db3")
con = DBInterface

queries = [
    # Sets
    Dict("query" => "SELECT ALLYEAR FROM MILESTONYR", "entity" => "MILEYR"),
    Dict("query" => "SELECT ALLYEAR FROM MODLYEAR", "entity" => "MODLYR"),
    Dict("query" => "SELECT ALL_TS FROM ALL_TS", "entity" => "TSLICE"),
    Dict("query" => "SELECT ALL_REG FROM ALL_REG", "entity" => "REGION"),
    Dict("query" => "SELECT PRC FROM PRC", "entity" => "PROCESS"),
    Dict("query" => "SELECT COM_GRP FROM COM_GRP", "entity" => "COMGRP"),
    Dict("query" => "SELECT COM_GRP FROM COM", "entity" => "COMMTY"),
    Dict("query" => "SELECT CUR FROM CUR", "entity" => "CURRENCY"),
    Dict("query" => "SELECT REG,CUR FROM RDCUR", "entity" => "RDCUR"),
    Dict("query" => "SELECT R,C FROM RC", "entity" => "RC"),
    Dict("query" => "SELECT R,P FROM RP", "entity" => "RP"),
    Dict("query" => "SELECT R,P FROM RP_FLO", "entity" => "RP_FLO"),
    Dict("query" => "SELECT R,P FROM RP_STD", "entity" => "RP_STD"),
    Dict("query" => "SELECT ALL_REG,P FROM RP_IRE", "entity" => "RP_IRE"),
    Dict("query" => "SELECT R,P FROM RP_STG", "entity" => "RP_STG"),
    Dict("query" => "SELECT R,P FROM RP_PGACT", "entity" => "RP_PGACT"),
    Dict("query" => "SELECT R,P FROM RP_PGFLO", "entity" => "RP_PGFLO"),
    Dict("query" => "SELECT REG,PRC FROM PRC_ACT", "entity" => "PRC_ACT"),
    Dict("query" => "SELECT REG,PRC FROM PRC_VINT", "entity" => "PRC_VINT"),
    Dict("query" => "SELECT R,P,IE FROM RP_AIRE", "entity" => "RP_AIRE"),
    Dict("query" => "SELECT REG,COM FROM DEM", "entity" => "DEM"),
    Dict("query" => "SELECT REG,COM_GRP,COM FROM COM_GMAP", "entity" => "COM_GMAP"),
    Dict("query" => "SELECT REG,PRC,COM,IO FROM TOP", "entity" => "TOP"),
    Dict("query" => "SELECT ALL_REG,PRC,ALL_TS FROM PRC_TS", "entity" => "PRC_TS"),
    Dict("query" => "SELECT R,P,ALL_TS FROM RPS_S1", "entity" => "RPS_S1"),
    Dict("query" => "SELECT R,P,S FROM RPS_STG", "entity" => "RPS_STG"),
    Dict("query" => "SELECT ALL_REG,ALL_TS,ALL_TS2 FROM TS_MAP", "entity" => "TS_MAP"),
    Dict("query" => "SELECT R,S,S2 FROM RS_PRETS", "entity" => "RS_PRETS"),
    Dict("query" => "SELECT R,P,C FROM RPC", "entity" => "RPC"),
    Dict("query" => "SELECT R,P,C FROM RPC_PG", "entity" => "RPC_PG"),
    Dict("query" => "SELECT ALL_REG,P,C,IE FROM RPC_IRE", "entity" => "RPC_IRE"),
    Dict("query" => "SELECT R,P,C FROM RPC_STG", "entity" => "RPC_STG"),
    Dict("query" => "SELECT REG,PRC,COM FROM PRC_STGTSS", "entity" => "PRC_STGTSS"),
    Dict("query" => "SELECT R,P,CG,IO FROM RPG_ACE", "entity" => "RPG_ACE"),
    Dict("query" => "SELECT REG,PRC,CG FROM RPC_ACE", "entity" => "RPC_ACE"),
    Dict("query" => "SELECT R,T,P,S,BD FROM AFS", "entity" => "AFS"),
    Dict("query" => "SELECT R,ALLYEAR,P FROM RTP", "entity" => "RTP"),
    Dict("query" => "SELECT R,ALLYEAR,P FROM RTP_VARA", "entity" => "RTP_VARA"),
    Dict("query" => "SELECT R,ALLYEAR,P,CUR FROM RTP_IPRI", "entity" => "RTP_IPRI"),
    Dict("query" => "SELECT R,T,P FROM RTP_VARP", "entity" => "RTP_VARP"),
    Dict("query" => "SELECT R,P,C,ALL_TS FROM RPCS_VAR", "entity" => "RPCS_VAR"),
    Dict("query" => "SELECT REG,PRC,CG,CG2 FROM RPCC_FFUNC", "entity" => "RPCC_FFUNC"),
    Dict(
        "query" => "SELECT REG,ALLYEAR,ALLYEAR2,PRC FROM RTP_VINTYR",
        "entity" => "RTP_VINTYR",
    ),
    Dict("query" => "SELECT R,ALLYEAR,C,ALL_TS FROM RTCS_VARC", "entity" => "RTCS"),
    Dict("query" => "SELECT R,ALLYEAR,C,S,LIM FROM RCS_COMBAL", "entity" => "RCS_COMBAL"),
    Dict("query" => "SELECT R,ALLYEAR,C,S,LIM FROM RCS_COMPRD", "entity" => "RCS_COMPRD"),
    Dict("query" => "SELECT R,ALLYEAR,C,S FROM RHS_COMPRD", "entity" => "RHS_COMPRD"),
    Dict("query" => "SELECT R,P,CG,CG2,S FROM RPFF_GGS", "entity" => "RP_PTRAN"),
    Dict("query" => "SELECT R,ALLYEAR,T,PRC FROM COEF_CPT", "entity" => "RTP_CPTYR"),
    Dict("query" => "SELECT R,T,ALLYEAR,CUR FROM OBJ_LINT", "entity" => "IS_LINT"),
    Dict("query" => "SELECT R,P,CUR,ALLYEAR FROM OB_ACT", "entity" => "IS_ACOST"),
    # Parameters
    Dict("query" => "SELECT ALL_REG,TS,value FROM G_YRFR", "entity" => "G_YRFR"),
    Dict("query" => "SELECT R,ALL_TS,value FROM RS_STGPRD", "entity" => "RS_STGPRD"),
    Dict("query" => "SELECT R,S,S2,value FROM RS_FR", "entity" => "RS_FR"),
    Dict("query" => "SELECT REG,PRC,value FROM PRC_CAPACT", "entity" => "PRC_CAPACT"),
    Dict("query" => "SELECT REG,PRC,value FROM PRC_SC", "entity" => "PRC_SC"),
    Dict("query" => "SELECT R,ALL_TS,value FROM RS_STGAV", "entity" => "RS_STGAV"),
    Dict("query" => "SELECT R,T,C,S,S2,value FROM RTCS_FR", "entity" => "RTCS_FR"),
    Dict("query" => "SELECT REG,ALLYEAR,COM,value FROM COM_PROJ", "entity" => "COM_PROJ"),
    Dict("query" => "SELECT REG,ALLYEAR,COM,TS,value FROM COM_IE", "entity" => "COM_IE"),
    Dict("query" => "SELECT REG,ALLYEAR,COM,TS,value FROM COM_FR", "entity" => "COM_FR"),
    Dict(
        "query" => "SELECT REG,ALLYEAR,PRC,value FROM NCAP_PASTI",
        "entity" => "NCAP_PASTI",
    ),
    Dict("query" => "SELECT REG,ALLYEAR,PRC,BD,value FROM CAP_BND", "entity" => "CAP_BND"),
    Dict(
        "query" => "SELECT REG,ALLYEAR,PRC,LIM,value FROM NCAP_BND",
        "entity" => "NCAP_BND",
    ),
    Dict("query" => "SELECT R,ALLYEAR,T,PRC,value FROM COEF_CPT", "entity" => "COEF_CPT"),
    Dict(
        "query" => "SELECT R,ALLYEAR,T,PRC,S,BD,value FROM COEF_AF",
        "entity" => "COEF_AF",
    ),
    Dict(
        "query" => "SELECT REG,ALLYEAR,PRC,CG,C,CG2,TS,value FROM COEF_PTRAN",
        "entity" => "COEF_PTRAN",
    ),
    Dict(
        "query" => "SELECT REG,ALLYEAR,PRC,C,CG,TS,BD,value FROM FLO_SHAR",
        "entity" => "FLO_SHAR",
    ),
    Dict(
        "query" => "SELECT REG,ALLYEAR,PRC,CG,value FROM PRC_ACTFLO",
        "entity" => "PRC_ACTFLO",
    ),
    Dict("query" => "SELECT REG,ALLYEAR,PRC,value FROM STG_EFF", "entity" => "STG_EFF"),
    Dict("query" => "SELECT REG,ALLYEAR,PRC,S,value FROM STG_LOSS", "entity" => "STG_LOSS"),
    Dict("query" => "SELECT REG,ALLYEAR,PRC,S,value FROM STG_CHRG", "entity" => "STG_CHRG"),
    Dict("query" => "SELECT REG,YEAR,PRC,CG,TS,value FROM ACT_EFF", "entity" => "ACT_EFF"),
    Dict("query" => "SELECT R,YEAR,CUR,value FROM OBJ_PVT", "entity" => "OBJ_PVT"),
    Dict("query" => "SELECT R,T,ALLYEAR,CUR,value FROM OBJ_LINT", "entity" => "OBJ_LINT"),
    Dict("query" => "SELECT R,P,CUR,ALLYEAR,value FROM OB_ACT", "entity" => "OBJ_ACOST"),
    Dict(
        "query" => "SELECT R,ALLYEAR,P,C,S,IE,CUR,value FROM OBJ_IPRIC",
        "entity" => "OBJ_IPRIC",
    ),
    Dict("query" => "SELECT R,YEAR,P,CUR,value FROM COEF_OBINV", "entity" => "COEF_OBINV"),
    Dict("query" => "SELECT R,YEAR,P,CUR,value FROM COEF_OBFIX", "entity" => "COEF_OBFIX"),
]

function create_symbol(symbol::String, val::Any)
    eval(Meta.parse("$symbol = val"))
end

function parse_year(df::DataFrame)::DataFrame
    year_cols = ["ALLYEAR", "ALLYEAR2", "T", "YEAR"]
    y_cols = intersect(names(df), year_cols)
    for y_col in y_cols
        df[!, y_col] = parse.(Int16, df[!, y_col])
    end
    return df
end

function read_data(queries::Vector{Dict{String,String}})::Dict{String,DataFrame}
    data = Dict()
    for q in queries
        df = DataFrame(con.execute(db, q["query"]))
        data[q["entity"]] = parse_year(df)
    end
    return data
end

data = read_data(queries)

# Create global variables
symbol, val = (nothing, nothing)

# Create sets and parameters by iterating through data and changing values of global variables
for (k, df) in data
    row_number = nrow(df)
    col_number = ncol(df)
    # One-dimensional set
    if row_number > 0 && col_number == 1
        v = Set(values(df[!, 1]))
        # Multi-dimensional set or parameter
    elseif row_number > 0 && col_number > 1
        if "value" in names(df)
            dict = OrderedDict(Tuple.(eachrow(df[:, Not(:value)])) .=> df.value)
            v = Containers.SparseAxisArray(dict)
        else
            v = Set(Tuple.(eachrow(df)))
        end
        # Empty set or parameter
    else
        v = nothing
    end
    global symbol, val = (k, v)
    create_symbol(symbol, val)
end
