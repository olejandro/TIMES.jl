# Input data specs
const data_info = Dict(
    # Sets
    "MILEYR" => "SELECT ALLYEAR FROM MILESTONYR",
    "MODLYR" => "SELECT ALLYEAR FROM MODLYEAR",
    "TSLICE" => "SELECT uni AS ALL_TS FROM ALL_TS",
    "REGION" => "SELECT uni AS ALL_REG FROM ALL_REG",
    "PROCESS" => "SELECT uni AS PRC FROM PRC",
    "COMGRP" => "SELECT uni AS COM_GRP FROM COM_GRP",
    "COMMTY" => "SELECT COM_GRP FROM COM",
    "CURRENCY" => "SELECT uni AS CUR FROM CUR",
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
    "TS_MAP" => "SELECT ALL_REG_0 AS ALL_REG, ALL_TS_1 AS ALL_TS, ALL_TS_2 AS ALL_TS2 FROM TS_MAP",
    "RS_PRETS" => "SELECT R_0 AS R, S_1 AS S, S_2 AS S2 FROM RS_PRETS",
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
    "RPCC_FFUNC" => "SELECT REG_0 AS REG, PRC_1 AS PRC, CG_2 AS CG, CG_3 AS CG2 FROM RPCC_FFUNC",
    "RTP_VINTYR" => "SELECT ALL_REG_0 AS ALL_REG, ALLYEAR_1 AS ALLYEAR, ALLYEAR_2 AS ALLYEAR2, PRC_3 AS PRC FROM RTP_VINTYR",
    "RTCS" => "SELECT R,ALLYEAR,C,ALL_TS FROM RTCS_VARC",
    "RCS_COMBAL" => "SELECT R,ALLYEAR,C,S,LIM FROM RCS_COMBAL",
    "RCS_COMPRD" => "SELECT R,ALLYEAR,C,S,LIM FROM RCS_COMPRD",
    "RHS_COMBAL" => "SELECT R,ALLYEAR,C,S FROM RHS_COMBAL",
    "RHS_COMPRD" => "SELECT R,ALLYEAR,C,S FROM RHS_COMPRD",
    "RP_PTRAN" => "SELECT R_0 AS R, P_1 AS P, CG_2 AS CG, CG_3 AS CG2, S_4 AS S FROM RPFF_GGS",
    "RTP_CPTYR" => "SELECT R,ALLYEAR,T,PRC FROM COEF_CPT",
    "IS_LINT" => "SELECT R,T,ALLYEAR,CUR FROM OBJ_LINT",
    "IS_ACOST" => "SELECT R,P,CUR,ALLYEAR FROM OB_ACT",
    # Parameters
    "G_YRFR" => "SELECT ALL_REG,TS,value FROM G_YRFR",
    "RS_STGPRD" => "SELECT R,ALL_TS,value FROM RS_STGPRD",
    "RS_FR" => "SELECT R_0 AS R, S_1 AS S, S_2 AS S2,value FROM RS_FR",
    "PRC_CAPACT" => "SELECT REG,PRC,value FROM PRC_CAPACT",
    "PRC_SC" => "SELECT REG,PRC,value FROM PRC_SC",
    "RS_STGAV" => "SELECT R,ALL_TS,value FROM RS_STGAV",
    "RTCS_FR" => "SELECT R_0 AS R, T_1 AS T, C_2 AS C, S_3 AS S, S_4 AS S2,value FROM RTCS_FR",
    "COM_PROJ" => "SELECT REG,ALLYEAR,COM,value FROM COM_PROJ",
    "COM_IE" => "SELECT REG,ALLYEAR,COM,TS,value FROM COM_IE",
    "COM_FR" => "SELECT REG,ALLYEAR,COM,TS,value FROM COM_FR",
    "NCAP_PASTI" => "SELECT REG,ALLYEAR,PRC,value FROM NCAP_PASTI",
    "CAP_BND" => "SELECT REG,ALLYEAR,PRC,BD,value FROM CAP_BND",
    "NCAP_BND" => "SELECT REG,ALLYEAR,PRC,LIM,value FROM NCAP_BND",
    "COEF_CPT" => "SELECT R,ALLYEAR,T,PRC,value FROM COEF_CPT",
    "COEF_AF" => "SELECT R,ALLYEAR,T,PRC,S,BD,value FROM COEF_AF",
    "COEF_PTRAN" => "SELECT REG_0 AS REG, ALLYEAR_1 AS ALLYEAR, PRC_2 AS PRC, CG_3 AS CG, C_4 AS C, CG_5 AS CG2, S_6 AS S,value FROM COEF_PTRAN",
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

function parse_year(df::DataFrames.DataFrame)::DataFrames.DataFrame
    year_cols = ["ALLYEAR", "ALLYEAR2", "T", "YEAR"]
    y_cols = intersect(names(df), year_cols)
    for y_col in y_cols
        df[!, y_col] = parse.(Int16, df[!, y_col])
    end
    return df
end

function read_data(file_path::String)::Dict{String,DataFrames.DataFrame}
    db = SQLite.DB(file_path)
    return Dict{String,DataFrames.DataFrame}(
        k => parse_year(
            DataFrames.DataFrame(SQLite.DBInterface.execute(db, query))
        ) for (k, query) in data_info
    )
end

function create_symbol(df::DataFrames.DataFrame)
    _, col_number = size(df)
    if col_number == 0
        # Return an error
        # TODO: handle this differently if it becomes an issue
        error("DataFrame has no columns.")
    end
    if col_number == 1
        # One-dimensional set
        return values(df[!, 1])
    end
    # Multi-dimensional set or parameter
    if "value" in names(df)
        return Dict(Tuple.(eachrow(df[:, DataFrames.Not(:value)])) .=> df.value)
    else
        return Tuple.(eachrow(df))
    end
end

function create_read_symbols(data::Dict{String,DataFrames.DataFrame})
    return Dict(Symbol(k) => create_symbol(v) for (k, v) in data)
end
