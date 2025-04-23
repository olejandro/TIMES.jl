using Profile
using ProfileView

function run_model()

    include("demo.jl")

end

# First run is for precompilation
@time "End to end model run for precompilation" solved_model = run_model()

# Now profile the code
Profile.clear()
@profile @time "End to end model run for profiling" run_model()

ProfileView.view()
