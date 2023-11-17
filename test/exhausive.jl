using Mados: generate_allcombinations, calculate_combinationcount, ProductIterator

@testset "generate_allcombinations" begin
    _unwrap(x::Encoding) = x.encoding
    item0 = AgentModel(Item(1, 1, [1], [[(1, 0)]]), 1, 0.0, 0.0)
    @test [_unwrap(x) for x ∈ @inferred(generate_allcombinations(item0))] == [[0, 0, 0]]
    item1 = AgentModel(Item(1, 1, [1, 1], [[(1, 0)], [(1, 0)]]), 1, 0.0, 0.0)
    @test [_unwrap(x) for x ∈ @inferred(generate_allcombinations(item1))] == [[0, 0, 0, 0, 0]]
    item2 = AgentModel(Item(1, 1, [1], [[(1, 1)]]), 1, 0.0, 0.0)
    @test Set([_unwrap(x) for x ∈ @inferred(generate_allcombinations(item2))]) == Set([[0, 0, 0], [0, 0, 1], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 1]])
    item3 = AgentModel(Item(1, 1, [1, 1], [[(1, 2)], [(1, 5)]]), 1, 0.0, 0.0)
    result3 = collect(@inferred(generate_allcombinations(item3)))
    @test typeof(result3) == Vector{Encoding}
    @test length(result3) == 6 * 21 * 8
    item4 = AgentModel(Item(1, 1, [1, 1, 1], [[(1, 10)], [(1, 15)], [(1, 21)]]), 1, 0.0, 0.0)
    result4 = @inferred generate_allcombinations(item4)
    # @test_broken eltype(result4) == Encoding
    @test length(result4) == calculate_combinationcount([10 + 15 + 21, 10, 15, 21])
end

@testset "calculate_combinationcount" begin
    @test @inferred(calculate_combinationcount([0, 0])) == 1
    @test @inferred(calculate_combinationcount([0, 1])) == 3
    @test @inferred(calculate_combinationcount([0, 2])) == 6
    @test @inferred(calculate_combinationcount([0, 3])) == 10
    @test @inferred(calculate_combinationcount(Int16[6, 3])) == 7 * 10
    @test @inferred(calculate_combinationcount([6, 3, 2])) == 7 * 10 * 6
    @test @inferred(calculate_combinationcount([1000, 10000, 10000, 10000, 1000])) == typemax(Int)
    @test @inferred(calculate_combinationcount(Int8[120, 120])) == 121 * 7381
end

@testset "ProductIterator" begin
    @test @inferred(collect(ProductIterator([[1, 2, 3]]))) == [[1], [2], [3]]
    @test @inferred(collect(ProductIterator([1:3]))) == [[1], [2], [3]]
    @test @inferred(collect(ProductIterator([1:3, 1:4]))) == [[1, 1], [2, 1], [3, 1], [1, 2], [2, 2], [3, 2], [1, 3], [2, 3], [3, 3], [1, 4], [2, 4], [3, 4]]
    @test @inferred(collect(ProductIterator([['a', 'b'], ['c', 'd'], ['e', 'f']]))) == [['a', 'c', 'e'], ['b', 'c', 'e'], ['a', 'd', 'e'], ['b', 'd', 'e'], ['a', 'c', 'f'], ['b', 'c', 'f'], ['a', 'd', 'f'], ['b', 'd', 'f']]
    gen = (i^2 for i = 1:3)
    @test @inferred(collect(ProductIterator([gen, gen]))) == [[1, 1], [4, 1], [9, 1], [1, 4], [4, 4], [9, 4], [1, 9], [4, 9], [9, 9]]
end