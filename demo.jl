using JuMP;
using HiGHS;
using TIMES;
#using GAMS;

@time "Create demo" demo = TIMES.create_model("PROTO.db3")

# Set solver
set_optimizer(demo, HiGHS.Optimizer)
#set_optimizer(model, GAMS.Optimizer)
#set_optimizer_attribute(model, GAMS.Solver(), "CPLEX")

@time "Solve model" optimize!(demo)

# Print solution summary
solution_summary(demo)
