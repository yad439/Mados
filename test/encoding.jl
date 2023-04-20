using Mados: SimulationResult, rate_local, rate_central, cost_local, cost_central, demand_local, demand_central,
    satisfied_local, satisfied_central, unsatisfied_local, unsatisfied_central

@testset "Rates" begin
    result1 = SimulationResult(1.0, 2.0, 10, 20, 5, 4)
    @test @inferred(cost_local(result1)) == 1
    @test @inferred(cost_central(result1)) == 2
    @test @inferred(demand_local(result1)) == 10
    @test @inferred(demand_central(result1)) == 20
    @test @inferred(satisfied_local(result1)) == 5
    @test @inferred(satisfied_central(result1)) == 4
    @test @inferred(unsatisfied_local(result1)) == 5
    @test @inferred(unsatisfied_central(result1)) == 16
    @test @inferred(rate_local(result1)) == 1 // 2
    @test @inferred(rate_central(result1)) == 1 // 5

    result2 = SimulationResult(1.0, 2.0, 10, 20, 0, 0)
    @test @inferred(cost_local(result2)) == 1
    @test @inferred(cost_central(result2)) == 2
    @test @inferred(demand_local(result2)) == 10
    @test @inferred(demand_central(result2)) == 20
    @test @inferred(satisfied_local(result2)) == 0
    @test @inferred(satisfied_central(result2)) == 0
    @test @inferred(unsatisfied_local(result2)) == 10
    @test @inferred(unsatisfied_central(result2)) == 20
    @test @inferred(rate_local(result2)) == 0
    @test @inferred(rate_central(result2)) == 0

    result3 = SimulationResult(1.0, 2.0, 10, 20, 10, 20)
    @test @inferred(cost_local(result3)) == 1
    @test @inferred(cost_central(result3)) == 2
    @test @inferred(demand_local(result3)) == 10
    @test @inferred(demand_central(result3)) == 20
    @test @inferred(satisfied_local(result3)) == 10
    @test @inferred(satisfied_central(result3)) == 20
    @test @inferred(unsatisfied_local(result3)) == 0
    @test @inferred(unsatisfied_central(result3)) == 0
    @test @inferred(rate_local(result3)) == 1
    @test @inferred(rate_central(result3)) == 1

    result4 = SimulationResult(1.0, 2.0, 0, 0, 0, 0)
    @test @inferred(cost_local(result4)) == 1
    @test @inferred(cost_central(result4)) == 2
    @test @inferred(demand_local(result4)) == 0
    @test @inferred(demand_central(result4)) == 0
    @test @inferred(satisfied_local(result4)) == 0
    @test @inferred(satisfied_central(result4)) == 0
    @test @inferred(unsatisfied_local(result4)) == 0
    @test @inferred(unsatisfied_central(result4)) == 0
    @test @inferred(rate_local(result4)) == 1
    @test @inferred(rate_central(result4)) == 1
end