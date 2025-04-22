using JuMP
using HiGHS
using TIMES

@time "Create demo" demo = TIMES.create_model("PROTO.db3")
set_optimizer(demo, HiGHS.Optimizer)
@time "Solve model" optimize!(demo)
solution_summary(demo)
