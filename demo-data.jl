using SQLite;
using DataFrames;
using JuMP;
using OrderedCollections: OrderedDict;

db = SQLite.DB("PROTO.db3")
con = DBInterface

# Input data specs
data_info = Dict(
    # Sets
    "MILEYR" => "SELECT ALLYEAR FROM MILESTONYR",
    "MODLYR" => "SELECT ALLYEAR FROM MODLYEAR",
    "TSLICE" => "SELECT ALL_TS FROM ALL_TS",
    "REGION" => "SELECT ALL_REG FROM ALL_REG",
    "PROCESS" => "SELECT PRC FROM PRC",
    "COMGRP" => "SELECT COM_GRP FROM COM_GRP",
    "COMMTY" => "SELECT COM_GRP FROM COM",
    "CURRENCY" => "SELECT CUR FROM CUR",
    "RDCUR" => "SELECT REG,CUR FROM RDCUR",
    "RC" => "SELECT R,C FROM RC",
    "RP" => "SELECT R,P FROM RP",
    "RP_FLO" => "SELECT R,P FROM RP_FLO",
    "RP_STD" => "SELECT R,P FROM RP_STD",
    "RP_IRE" => "SELECT ALL_REG,P FROM RP_IRE",
    "RP_STG" => "SELECT R,P FROM RP_STG",
    "RP_PGACT" => "SELECT R,P FROM RP_PGACT",
    "RP_PGFLO" => "SELECT R,P FROM RP_PGFLO",
    "PRC_ACT" => "SELECT REG,PRC FROM PRC_ACT",
    "PRC_VINT" => "SELECT REG,PRC FROM PRC_VINT",
    "RP_AIRE" => "SELECT R,P,IE FROM RP_AIRE",
    "DEM" => "SELECT REG,COM FROM DEM",
    "COM_GMAP" => "SELECT REG,COM_GRP,COM FROM COM_GMAP",
    "TOP" => "SELECT REG,PRC,COM,IO FROM TOP",
    "PRC_TS" => "SELECT ALL_REG,PRC,ALL_TS FROM PRC_TS",
    "RPS_S1" => "SELECT R,P,ALL_TS FROM RPS_S1",
    "RPS_STG" => "SELECT R,P,S FROM RPS_STG",
    "TS_MAP" => "SELECT ALL_REG,ALL_TS,ALL_TS2 FROM TS_MAP",
    "RS_PRETS" => "SELECT R,S,S2 FROM RS_PRETS",
    "RPC" => "SELECT R,P,C FROM RPC",
    "RPC_PG" => "SELECT R,P,C FROM RPC_PG",
    "RPC_IRE" => "SELECT ALL_REG,P,C,IE FROM RPC_IRE",
    "RPC_STG" => "SELECT R,P,C FROM RPC_STG",
    "PRC_STGTSS" => "SELECT REG,PRC,COM FROM PRC_STGTSS",
    "RPG_ACE" => "SELECT R,P,CG,IO FROM RPG_ACE",
    "RPC_ACE" => "SELECT REG,PRC,CG FROM RPC_ACE",
    "AFS" => "SELECT R,T,P,S,BD FROM AFS",
    "RTP" => "SELECT R,ALLYEAR,P FROM RTP",
    "RTP_VARA" => "SELECT R,ALLYEAR,P FROM RTP_VARA",
    "RTP_IPRI" => "SELECT R,ALLYEAR,P,CUR FROM RTP_IPRI",
    "RTP_VARP" => "SELECT R,T,P FROM RTP_VARP",
    "RPCS_VAR" => "SELECT R,P,C,ALL_TS FROM RPCS_VAR",
    "RPCC_FFUNC" => "SELECT REG,PRC,CG,CG2 FROM RPCC_FFUNC",
    "RTP_VINTYR" => "SELECT ALL_REG,ALLYEAR,ALLYEAR2,PRC FROM RTP_VINTYR",
    "RTCS" => "SELECT R,ALLYEAR,C,ALL_TS FROM RTCS_VARC",
    "RCS_COMBAL" => "SELECT R,ALLYEAR,C,S,LIM FROM RCS_COMBAL",
    "RCS_COMPRD" => "SELECT R,ALLYEAR,C,S,LIM FROM RCS_COMPRD",
    "RHS_COMBAL" => "SELECT R,ALLYEAR,C,S FROM RHS_COMBAL",
    "RHS_COMPRD" => "SELECT R,ALLYEAR,C,S FROM RHS_COMPRD",
    "RP_PTRAN" => "SELECT R,P,CG,CG2,S FROM RPFF_GGS",
    "RTP_CPTYR" => "SELECT R,ALLYEAR,T,PRC FROM COEF_CPT",
    "IS_LINT" => "SELECT R,T,ALLYEAR,CUR FROM OBJ_LINT",
    "IS_ACOST" => "SELECT R,P,CUR,ALLYEAR FROM OB_ACT",
    # Parameters
    "G_YRFR" => "SELECT ALL_REG,TS,value FROM G_YRFR",
    "RS_STGPRD" => "SELECT R,ALL_TS,value FROM RS_STGPRD",
    "RS_FR" => "SELECT R,S,S2,value FROM RS_FR",
    "PRC_CAPACT" => "SELECT REG,PRC,value FROM PRC_CAPACT",
    "PRC_SC" => "SELECT REG,PRC,value FROM PRC_SC",
    "RS_STGAV" => "SELECT R,ALL_TS,value FROM RS_STGAV",
    "RTCS_FR" => "SELECT R,T,C,S,S2,value FROM RTCS_FR",
    "COM_PROJ" => "SELECT REG,ALLYEAR,COM,value FROM COM_PROJ",
    "COM_IE" => "SELECT REG,ALLYEAR,COM,TS,value FROM COM_IE",
    "COM_FR" => "SELECT REG,ALLYEAR,COM,TS,value FROM COM_FR",
    "NCAP_PASTI" => "SELECT REG,ALLYEAR,PRC,value FROM NCAP_PASTI",
    "CAP_BND" => "SELECT REG,ALLYEAR,PRC,BD,value FROM CAP_BND",
    "NCAP_BND" => "SELECT REG,ALLYEAR,PRC,LIM,value FROM NCAP_BND",
    "COEF_CPT" => "SELECT R,ALLYEAR,T,PRC,value FROM COEF_CPT",
    "COEF_AF" => "SELECT R,ALLYEAR,T,PRC,S,BD,value FROM COEF_AF",
    "COEF_PTRAN" => "SELECT REG,ALLYEAR,PRC,CG,C,CG2,S,value FROM COEF_PTRAN",
    "FLO_SHAR" => "SELECT REG,ALLYEAR,PRC,C,CG,TS,BD,value FROM FLO_SHAR",
    "PRC_ACTFLO" => "SELECT REG,ALLYEAR,PRC,CG,value FROM PRC_ACTFLO",
    "STG_EFF" => "SELECT REG,ALLYEAR,PRC,value FROM STG_EFF",
    "STG_LOSS" => "SELECT REG,ALLYEAR,PRC,S,value FROM STG_LOSS",
    "STG_CHRG" => "SELECT REG,ALLYEAR,PRC,S,value FROM STG_CHRG",
    "ACT_EFF" => "SELECT REG,YEAR,PRC,CG,TS,value FROM ACT_EFF",
    "OBJ_PVT" => "SELECT R,YEAR,CUR,value FROM OBJ_PVT",
    "OBJ_LINT" => "SELECT R,T,ALLYEAR,CUR,value FROM OBJ_LINT",
    "OBJ_ACOST" => "SELECT R,P,CUR,ALLYEAR,value FROM OB_ACT",
    "OBJ_IPRIC" => "SELECT R,ALLYEAR,P,C,S,IE,CUR,value FROM OBJ_IPRIC",
    "COEF_OBINV" => "SELECT R,YEAR,P,CUR,value FROM COEF_OBINV",
    "COEF_OBFIX" => "SELECT R,YEAR,P,CUR,value FROM COEF_OBFIX",
)

function parse_year(df::DataFrame)::DataFrame
    year_cols = ["ALLYEAR", "ALLYEAR2", "T", "YEAR"]
    y_cols = intersect(names(df), year_cols)
    for y_col in y_cols
        df[!, y_col] = parse.(Int16, df[!, y_col])
    end
    return df
end

function read_data(data_info::Dict{String,String})::Dict{String,DataFrame}
    data = Dict()
    for (k, query) in data_info
        df = DataFrame(con.execute(db, query))
        data[k] = parse_year(df)
    end
    return data
end

function create_symbol(df::DataFrame)
    row_number = nrow(df)
    col_number = ncol(df)

    if row_number > 0 && col_number == 1
        # One-dimensional set
        value = Set(values(df[!, 1]))
    elseif row_number > 0 && col_number > 1
        # Multi-dimensional set or parameter
        if "value" in names(df)
            value = Dict(Tuple.(eachrow(df[:, Not(:value)])) .=> df.value)
        else
            value = Set(Tuple.(eachrow(df)))
        end

    else
        # Empty set or parameter
        value = nothing
    end
    return value
end

data = read_data(data_info)

# Create all the symbols from the data
MILEYR = create_symbol(data["MILEYR"])
MODLYR = create_symbol(data["MODLYR"])
TSLICE = create_symbol(data["TSLICE"])
REGION = create_symbol(data["REGION"])
PROCESS = create_symbol(data["PROCESS"])
COMGRP = create_symbol(data["COMGRP"])
COMMTY = create_symbol(data["COMMTY"])
CURRENCY = create_symbol(data["CURRENCY"])
RDCUR = create_symbol(data["RDCUR"])
RC = create_symbol(data["RC"])
RP = create_symbol(data["RP"])
RP_FLO = create_symbol(data["RP_FLO"])
RP_STD = create_symbol(data["RP_STD"])
RP_IRE = create_symbol(data["RP_IRE"])
RP_STG = create_symbol(data["RP_STG"])
RP_PGACT = create_symbol(data["RP_PGACT"])
RP_PGFLO = create_symbol(data["RP_PGFLO"])
PRC_ACT = create_symbol(data["PRC_ACT"])
PRC_VINT = create_symbol(data["PRC_VINT"])
RP_AIRE = create_symbol(data["RP_AIRE"])
DEM = create_symbol(data["DEM"])
COM_GMAP = create_symbol(data["COM_GMAP"])
TOP = create_symbol(data["TOP"])
PRC_TS = create_symbol(data["PRC_TS"])
RPS_S1 = create_symbol(data["RPS_S1"])
RPS_STG = create_symbol(data["RPS_STG"])
TS_MAP = create_symbol(data["TS_MAP"])
RS_PRETS = create_symbol(data["RS_PRETS"])
RPC = create_symbol(data["RPC"])
RPC_PG = create_symbol(data["RPC_PG"])
RPC_IRE = create_symbol(data["RPC_IRE"])
RPC_STG = create_symbol(data["RPC_STG"])
PRC_STGTSS = create_symbol(data["PRC_STGTSS"])
RPG_ACE = create_symbol(data["RPG_ACE"])
RPC_ACE = create_symbol(data["RPC_ACE"])
AFS = create_symbol(data["AFS"])
RTP = create_symbol(data["RTP"])
RTP_VARA = create_symbol(data["RTP_VARA"])
RTP_IPRI = create_symbol(data["RTP_IPRI"])
RTP_VARP = create_symbol(data["RTP_VARP"])
RPCS_VAR = create_symbol(data["RPCS_VAR"])
RPCC_FFUNC = create_symbol(data["RPCC_FFUNC"])
RTP_VINTYR = create_symbol(data["RTP_VINTYR"])
RTCS = create_symbol(data["RTCS"])
RCS_COMBAL = create_symbol(data["RCS_COMBAL"])
RCS_COMPRD = create_symbol(data["RCS_COMPRD"])
RHS_COMBAL = create_symbol(data["RHS_COMBAL"])
RHS_COMPRD = create_symbol(data["RHS_COMPRD"])
RP_PTRAN = create_symbol(data["RP_PTRAN"])
RTP_CPTYR = create_symbol(data["RTP_CPTYR"])
IS_LINT = create_symbol(data["IS_LINT"])
IS_ACOST = create_symbol(data["IS_ACOST"])
G_YRFR = create_symbol(data["G_YRFR"])
RS_STGPRD = create_symbol(data["RS_STGPRD"])
RS_FR = create_symbol(data["RS_FR"])
PRC_CAPACT = create_symbol(data["PRC_CAPACT"])
PRC_SC = create_symbol(data["PRC_SC"])
RS_STGAV = create_symbol(data["RS_STGAV"])
RTCS_FR = create_symbol(data["RTCS_FR"])
COM_PROJ = create_symbol(data["COM_PROJ"])
COM_IE = create_symbol(data["COM_IE"])
COM_FR = create_symbol(data["COM_FR"])
NCAP_PASTI = create_symbol(data["NCAP_PASTI"])
CAP_BND = create_symbol(data["CAP_BND"])
NCAP_BND = create_symbol(data["NCAP_BND"])
COEF_CPT = create_symbol(data["COEF_CPT"])
COEF_AF = create_symbol(data["COEF_AF"])
COEF_PTRAN = create_symbol(data["COEF_PTRAN"])
FLO_SHAR = create_symbol(data["FLO_SHAR"])
PRC_ACTFLO = create_symbol(data["PRC_ACTFLO"])
STG_EFF = create_symbol(data["STG_EFF"])
STG_LOSS = create_symbol(data["STG_LOSS"])
STG_CHRG = create_symbol(data["STG_CHRG"])
ACT_EFF = create_symbol(data["ACT_EFF"])
OBJ_PVT = create_symbol(data["OBJ_PVT"])
OBJ_LINT = create_symbol(data["OBJ_LINT"])
OBJ_ACOST = create_symbol(data["OBJ_ACOST"])
OBJ_IPRIC = create_symbol(data["OBJ_IPRIC"])
COEF_OBINV = create_symbol(data["COEF_OBINV"])
COEF_OBFIX = create_symbol(data["COEF_OBFIX"])
