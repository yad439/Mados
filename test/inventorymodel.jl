using Mados: Item, Instance, Encoding, InventoryModel, AgentModel, variable_count, fastconstraint_count,
    slowconstraint_count, agentmodels, bounds, fastconstraints, evaluate, objectivevalue, slowconstraints, cost_local,
    cost_central

@testset "InventoryModel" begin
    item1 = Item(13, 3, [10, 11], [[(2, 5)], [(3, 7)]])
    item2 = Item(11, 3, [10], [[(2, 5), (4, 7)]])
    instance = Instance([item1, item2], 10)
    model = InventoryModel(instance, 0.95, 0.9)

    agents = @inferred agentmodels(model)

    @test length(agents) == 2
    @test @inferred(variable_count(agents[1])) == 5
    @test @inferred(variable_count(agents[2])) == 3
    @test agents[1].item == item1
    @test agents[2].item == item2
    @test agents[1].target_local == 0.95
    @test agents[2].target_local == 0.95
    @test agents[1].target_central == 0.9
    @test agents[2].target_central == 0.9
    @test agents[1].demands == [5, 7]
    @test agents[2].demands == [5 + 7]
end

@testset "AgentModel" begin
    item = Item(13, 3, [10, 11], [[(2, 5)], [(3, 7)]])
    model = AgentModel(item, 10, 0.95, 0.9)

    @test @inferred(variable_count(model)) == 5
    @test @inferred(fastconstraint_count(model)) == 4
    @test @inferred(slowconstraint_count(model)) == 2
    @test @inferred(bounds(model)) == [(0, 12), (0, 5), (0, 5), (0, 7), (0, 7)]

    @test @inferred(fastconstraints(model, Encoding([3, 5, 4, 1, 6]))) == [2, 0, 0, 4]
    @test @inferred(fastconstraints(model, Encoding([3, 0, 1, 0, 0]))) == [0, 0, 0, 0]
    @test @inferred(fastconstraints(model, Encoding([3, 0, 2, 1, 2]))) == [0, 0, 2, 0]

    result1 = @inferred evaluate(model, Encoding([20, 1, 10, 1, 10]))
    @test @inferred(objectivevalue(model, result1)) == 13(((1 * 10 + 9 * 5) + (2 * 10 + 8 * 3)) + 10 * 20)
    @test @inferred(slowconstraints(model, result1)) == [0, 0]

    result2 = @inferred evaluate(model, Encoding([5, 0, 3, 0, 3]))
    @test @inferred(slowconstraints(model, result2)) ≈ [0.95 - (3 + 3) / (5 + 7), 0.9 - 5 / 12]
end