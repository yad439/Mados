using Mados: calculate_combinationcount, ProductIterator

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