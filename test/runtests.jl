using Test
using TIMES

@testset "create_model" begin
    database = joinpath(@__DIR__, "..", "PROTO.db3")
    model = create_model(database)

    @test model isa TIMES.JuMP.Model
    @test !isempty(TIMES.JuMP.all_variables(model))
end
