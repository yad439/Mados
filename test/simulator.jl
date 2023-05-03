using Mados: Item, Instance, Encoding, simulateone, simulateall, cost_local, cost_central, demand_local, demand_central,
    satisfied_local, satisfied_central, unsatisfied_local, unsatisfied_central

@testset "simulateone" begin
    @testset "Two units, single order at each" begin
        item = Item(13, 3, [10, 11], [[(2, 5)], [(3, 7)]])
        policies = Encoding([20, 1, 10, 1, 10])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 7
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 0
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * ((1 * 10 + 9 * 5) + (2 * 10 + 8 * 3))
        @test cost_central(result) == 13 * 10 * 20
    end
    @testset "Single unit, two orders" begin
        item = Item(13, 3, [10], [[(2, 5), (4, 7)]])
        policies = Encoding([20, 1, 20])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 7
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 0
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 20 + 2 * 15 + 7 * 8)
        @test cost_central(result) == 13 * 10 * 20
    end
    @testset "One order, request to central" begin
        item = Item(13, 3, [4], [[(2, 5)]])
        policies = Encoding([20, 7, 10])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 5
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 10 + 4 * 5 + 5 * 10)
        @test cost_central(result) == 13 * (1 * 20 + 3 * 15 + 6 * 20)
    end
    @testset "Two orders, one partially unsatisfied" begin
        item = Item(13, 3, [4], [[(2, 5), (3, 7)]])
        policies = Encoding([20, 1, 10])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 7
        @test unsatisfied_local(result) == 2
        @test demand_central(result) == 5 + 7
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 10 + 1 * 5 + 4 * 0 + 4 * 10)
        @test cost_central(result) == 13 * (2 * 20 + 3 * 8 + 5 * 20)
    end
    @testset "Three orders, two requests" begin
        item = Item(13, 3, [4], [[(2, 5), (3, 2), (4, 7)]])
        policies = Encoding([30, 10, 15])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 2 + 7
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 5 + 2 + 7
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 15 + 1 * 10 + 1 * 8 + 2 * 1 + 2 * 6 + 3 * 15)
        @test cost_central(result) == 13 * (1 * 30 + 2 * 25 + 1 * 16 + 2 * 21 + 4 * 30)
    end
    @testset "Unsatisfied central" begin
        item = Item(13, 3, [4, 2], [[(2, 5)], [(3, 7)]])
        policies = Encoding([4, 1, 5, 1, 7])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 7
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 5 + 7
        @test unsatisfied_central(result) == 1 + 7
        @test cost_local(result) == 13 * ((1 * 5 + 4 * 0 + 3 * 4 + 2 * 5) + (2 * 7 + 4 * 0 + 1 * 4 + 3 * 7))
        @test cost_central(result) == 13 * (1 * 4 + 4 * 0 + 5 * 4)
    end
    @testset "One at local" begin
        item = Item(13, 3, [2], [[(2, 1), (5, 2)]])
        policies = Encoding([4, 0, 1])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 1 + 2
        @test unsatisfied_local(result) == 1
        @test demand_central(result) == 1 + 2
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 1 + 2 * 0 + 2 * 0 + 5 * 1)
        @test cost_central(result) == 13 * (1 * 4 + 3 * 3 + 3 * 2 + 3 * 4)
    end
    @testset "One at central" begin
        item = Item(13, 3, [2], [[(2, 1), (3, 2)]])
        policies = Encoding([1, 0, 1])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 1 + 2
        @test unsatisfied_local(result) == 2
        @test demand_central(result) == 1 + 2
        @test unsatisfied_central(result) == 2
        @test cost_local(result) == 13 * (1 * 1 + 6 * 0 + 3 * 1)
        @test cost_central(result) == 13 * (1 * 1 + 4 * 0 + 5 * 1)
    end
    @testset "Zero at local" begin
        item = Item(13, 3, [2], [[(2, 1), (5, 2)]])
        policies = Encoding([4, 0, 0])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 1 + 2
        @test satisfied_local(result) == 0
        @test demand_central(result) == 1 + 2
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 0
        @test cost_central(result) == 13 * (1 * 4 + 3 * 3 + 3 * 2 + 3 * 4)
    end
    @testset "Zero at cental" begin
        item = Item(13, 3, [2], [[(2, 2)]])
        policies = Encoding([0, 2, 4])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 2
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 2
        @test satisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 4 + 5 * 2 + 4 * 4)
        @test cost_central(result) == 0
    end
    @testset "Zero both" begin
        item = Item(13, 3, [2], [[(2, 1), (3, 1)]])
        policies = Encoding([0, 0, 0])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 2
        @test satisfied_local(result) == 0
        @test demand_central(result) == 2
        @test satisfied_central(result) == 0
        @test cost_local(result) == 0
        @test cost_central(result) == 0
    end
    @testset "Several events at one day" begin
        item = Item(13, 2, [2, 2], [[(2, 5), (4, 10)], [(4, 5)]])
        policies = Encoding([15, 5, 10, 0, 5])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 10 + 5
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 5 + 10 + 5
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * ((1 * 10 + 2 * 5 + 2 * 0 + 5 * 10) + (3 * 5 + 2 * 0 + 5 * 5))
        @test cost_central(result) == 13 * (1 * 15 + 2 * 10 + 2 * 0 + 5 * 15)
    end
    @testset "Several events at one day 2" begin
        item = Item(13, 2, [2, 2], [[(2, 3), (2, 2), (4, 5), (4, 5)], [(4, 2), (4, 3)]])
        policies = Encoding([15, 5, 10, 0, 5])

        result = @inferred simulateone(item, 10, policies)

        @test demand_local(result) == 5 + 10 + 5
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 5 + 10 + 5
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * ((1 * 10 + 2 * 5 + 2 * 0 + 5 * 10) + (3 * 5 + 2 * 0 + 5 * 5))
        @test cost_central(result) == 13 * (1 * 15 + 2 * 10 + 2 * 0 + 5 * 15)
    end
end
@testset "simulateall" begin
    @testset "One item" begin
        item = Item(13, 3, [10], [[(2, 5), (4, 7)]])
        policies = Encoding([20, 1, 20])
        instance = Instance([item], 10)

        result = @inferred simulateall(instance, [policies])

        @test demand_local(result) == 5 + 7
        @test unsatisfied_local(result) == 0
        @test demand_central(result) == 0
        @test unsatisfied_central(result) == 0
        @test cost_local(result) == 13 * (1 * 20 + 2 * 15 + 7 * 8)
        @test cost_central(result) == 13 * 10 * 20
    end
    @testset "Several items" begin
        item1 = Item(11, 3, [10, 11], [[(2, 5)], [(3, 7)]])
        item2 = Item(13, 3, [10], [[(2, 5), (4, 7)]])
        item3 = Item(17, 3, [2], [[(2, 1), (3, 1)]])
        item4 = Item(23, 3, [4], [[(2, 5), (3, 7)]])
        item5 = Item(29, 3, [4, 2], [[(2, 5)], [(3, 7)]])
        items = [item1, item2, item3, item4, item5]
        instance = Instance(items, 10)

        policies1 = Encoding([20, 1, 10, 1, 10])
        policies2 = Encoding([20, 1, 20])
        policies3 = Encoding([0, 0, 0])
        policies4 = Encoding([20, 1, 10])
        policies5 = Encoding([4, 1, 5, 1, 7])
        policies = [policies1, policies2, policies3, policies4, policies5]

        result = @inferred simulateall(instance, policies)

        @test demand_local(result) == (5 + 7) + (5 + 7) + 2 + (5 + 7) + (5 + 7)
        @test unsatisfied_local(result) == 0 + 0 + 2 + 2 + 0
        @test demand_central(result) == 0 + 0 + 2 + (5 + 7) + (5 + 7)
        @test unsatisfied_central(result) == 0 + 0 + 2 + 0 + (1 + 7)
        @test cost_local(result) == 11((1 * 10 + 9 * 5) + (2 * 10 + 8 * 3)) + 13(1 * 20 + 2 * 15 + 7 * 8) + 0 + 23(1 * 10 + 1 * 5 + 4 * 0 + 4 * 10) + 29((1 * 5 + 4 * 0 + 3 * 4 + 2 * 5) + (2 * 7 + 4 * 0 + 1 * 4 + 3 * 7))
        @test cost_central(result) == 11 * 10 * 20 + 13 * 10 * 20 + 0 + 23(2 * 20 + 3 * 8 + 5 * 20) + 29(1 * 4 + 4 * 0 + 5 * 4)
    end
end