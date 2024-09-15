# System Sets
YEAR = union(0, (1900:2200))
INOUT = Set(["IN", "OUT"])
IMPEXP = Set(["IMP", "EXP"])
LIM = Set(["LO", "UP", "FX", "N"])

TSLVL = Set(["ANNUAL", "SEASON", "WEEKLY", "DAYNITE"])

COM_TYPE = Set([
    "DEM",         # Demands
    "NRG",         # Energy
    "MAT",         # Material
    "ENV",         # Environmental
    "FIN",          # Financial
])

PRC_GRP = Set([
    "XTRACT",  # Extraction
    "RENEW",   # Renewables (limited)
    "PRE",     # Energy
    "PRW",     # Material (by weight)
    "PRV",     # Material (by volume)
    "REF",     # Refined Products
    "ELE",     # Electric Generation
    "HPL",     # Heat Generation
    "CHP",     # Combined Heat+Power
    "DMD",     # Demand Devices
    "DISTR",   # Distribution Systems
    "CORR",    # Corridor Device'
    "STG",     # Storage
    "NST",     # Night (Off-peak) Storage
    "IRE",     # Inter-region exchange (IMPort/EXPort)
    "STK",     # Stockpiling
    "MISC",    # Miscellaneous
    "STS",      # Time-slice storage (excluding night storages)
])

UPT = Set(["COLD", "WARM", "HOT"])

UC_NAME = Set([
    "COST",
    "DELIV",
    "TAX",
    "SUB",
    "EFF",
    "NET",
    "N",
    "GROWTH",
    "PERIOD",
    "PERDISC",
    "BUILDUP",
    "CUMSUM",
    "CUM+",
    "SYNC",
    "YES",
    "CAPACT",
    "CAPFLO",
    "NEWFLO",
    "ONLINE",
    "ANNUL",
    "INVCOST",
    "INVTAX",
    "INVSUB",
    "FLO_COST",
    "FLO_DELIV",
    "FLO_SUB",
    "FLO_TAX",
    "NCAP_COST",
    "NCAP_ITAX",
    "NCAP_ISUB",
])

UC_GRPTYPE = Set(["ACT", "FLO", "IRE", "CAP", "NCAP", "COMNET", "COMPRD", "COMCON", "UCN"])

UC_COST = Set(["COST", "DELIV", "TAX", "SUB", "ANNUL"])

COSTAGG = Set([
    "INV",
    "INVTAX",
    "INVSUB",
    "FOM",
    "FOMTAX",
    "FOMSUB",
    "COMTAX",
    "COMSUB",
    "FLOTAX",
    "FLOSUB",
    "INVTAXSUB",
    "INVALL",
    "FOMTAXSUB",
    "FOMALL",
    "FIX",
    "FIXTAX",
    "FIXSUB",
    "FIXTAXSUB",
    "FIXALL",
    "COMTAXSUB",
    "FLOTAXSUB",
    "ALLTAX",
    "ALLSUB",
    "ALLTAXSUB",
])

# Internal Sets	
OBV = Set(["OBJINV", "OBJFIX", "OBJVAR"])
