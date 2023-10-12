using Mados: _binarysearch

@testset "_binarysearch" begin
    @testset "manual" begin
        @test @inferred(_binarysearch(Base.Fix1(getindex, [true]), 1, 1)) == 1
        @test @inferred(_binarysearch(Base.Fix1(getindex, [true, true]), 1, 2)) == 1
        @test @inferred(_binarysearch(Base.Fix1(getindex, [true, true, true]), 1, 3)) == 1
        @test @inferred(_binarysearch(Base.Fix1(getindex, [true, true, true, true]), 1, 4,)) == 1
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false]), 1, 1)) == 0
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, false]), 1, 2)) == 0
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, false, false]), 1, 3)) == 0
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, false, false, false]), 1, 4)) == 0
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, true]), 1, 2)) == 2
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, true, true]), 1, 3)) == 2
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, true, true, true]), 1, 4)) == 2
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, false, false, true]), 1, 4,)) == 4
        @test @inferred(_binarysearch(Base.Fix1(getindex, [false, false, true, true, true]), 1, 5)) == 3
    end
    @testset "automatic" for n = 2:10, i = 1:n
        @test @inferred(_binarysearch(≥(i), 1, n)) == i
    end
end