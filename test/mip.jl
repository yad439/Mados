using Mados: Item, Instance, InventoryModel, agentmodels, solveknapsack, generate_allcombinations, getdemands

@testset "solveknapsack" begin
    item1 = Item(11, 3, [10, 11], [[(2, 5)], [(3, 7)]])
    item2 = Item(13, 3, [10], [[(2, 5), (4, 7)]])
    item3 = Item(17, 3, [2], [[(2, 1), (3, 1)]])
    item4 = Item(23, 3, [4], [[(2, 5), (3, 7)]])
    item5 = Item(29, 3, [4, 2], [[(2, 5)], [(3, 7)]])
    items = [item1, item2, item3, item4, item5]
    instance = Instance(items, 10)
    agents = agentmodels(InventoryModel(instance, 0.5, 0.5))
    encodings = generate_allcombinations.(agents)
    results = [[simulateone(item, 10, encoding) for encoding ∈ encodinggenerator] for (item, encodinggenerator) ∈ zip(items, encodings)]
    costs = [cost_local.(result) for result ∈ results]
    localsatisfied = [satisfied_local.(result) for result ∈ results]
    centralsatisfied = [satisfied_central.(result) for result ∈ results]
    centraldemands = [demand_central.(result) for result ∈ results]
    localdemands = [sum(getdemands(agent)) for agent ∈ agents]

    result = @inferred solveknapsack(costs, localsatisfied, centralsatisfied, localdemands, centraldemands, 0.5, 0.5)

    @test result.objective > 0
    @test length(result.indices) == length(items)
    @test all(i ∈ eachindex(simresult) for (i, simresult) ∈ zip(result.indices, results))
end