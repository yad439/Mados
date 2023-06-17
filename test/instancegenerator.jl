using Mados: generateinstance, generateitem, generateorders, validate

@testset "generateorders" begin
    result = @inferred generateorders(10, 1.0)

    @test 0 < length(result) ≤ 10
    @test all(n > 0 for (d, n) ∈ result)
    @test all(d ∈ 1:10 for (d, n) ∈ result)
end

@testset "generateitem" begin
    @testset "Normal generation" begin
        result = @inferred Nothing generateitem(10, 11, 1.0, 0.5, 0.0, 20.0, 0.5, 0.0, 10:20, 1:9)

        @test result.cost > 0.0
        @test 10 ≤ result.central_leadtime ≤ 20
        @test all(1 ≤ l ≤ 9 for l ∈ result.local_leadtimes)
        @test 0 < length(result.orders) ≤ 10
        @test all(n > 0 for unitorders ∈ result.orders for (d, n) ∈ unitorders)
        @test all(d ∈ 1:11 for unitorders ∈ result.orders for (d, n) ∈ unitorders)
    end
    @testset "No orders" begin
        result = @test_warn "No orders" (@inferred Nothing generateitem(10, 11, 0.0, 0.5, 0.0, 20.0, 0.5, 0.0, 10:20, 1:9))

        @test result ≡ nothing
    end
end

@testset "generateinstance" begin
    @testset "Normal generation" begin
        result = @inferred generateinstance(10, 10, 11, 1.0, 0.5, 0.0, 20.0, 0.5, 0.0, 10:20, 1:9)

        @test length(result.items) == 10
        @test result.period == 11
        @test all(item.cost > 0.0 for item ∈ result.items)
        @test all(10 ≤ item.central_leadtime ≤ 20 for item ∈ result.items)
        @test all(1 ≤ l ≤ 9 for item ∈ result.items for l ∈ item.local_leadtimes)
        @test all(0 < length(item.orders) ≤ 10 for item ∈ result.items)
        @test all(n > 0 for item ∈ result.items for unitorders ∈ item.orders for (d, n) ∈ unitorders)
        @test all(d ∈ 1:11 for item ∈ result.items for unitorders ∈ item.orders for (d, n) ∈ unitorders)
        @test (validate(result); true)
    end
    @testset "No orders for some" begin
        result = @test_warn "No orders" (@inferred generateinstance(20, 2, 11, 0.1, 0.5, 0.0, 20.0, 0.5, 0.0, 10:20, 1:9))

        @test length(result.items) < 50
        @test result.period == 11
        @test all(item.cost > 0.0 for item ∈ result.items)
        @test all(10 ≤ item.central_leadtime ≤ 20 for item ∈ result.items)
        @test all(1 ≤ l ≤ 9 for item ∈ result.items for l ∈ item.local_leadtimes)
        @test all(0 < length(item.orders) ≤ 2 for item ∈ result.items)
        @test all(n > 0 for item ∈ result.items for unitorders ∈ item.orders for (d, n) ∈ unitorders)
        @test all(d ∈ 1:11 for item ∈ result.items for unitorders ∈ item.orders for (d, n) ∈ unitorders)
        @test (validate(result); true)
    end
end