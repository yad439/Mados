using Mados: SeparateQueue, StorageEventQueue, enqueue!, dequeue!, push!

@testset "SeparateQueue" begin
    queue = SeparateQueue{String,Int8}()

    @test @inferred(isempty(queue))

    @inferred enqueue!(queue, Int8(2), "a")

    @test @inferred(!isempty(queue))

    @inferred enqueue!(queue, Int8(1), "b")

    @test @inferred(dequeue!(queue)) == (1, "b")
    @test @inferred(dequeue!(queue)) == (2, "a")
end

@testset "StorageEventQueue" begin
    queue = StorageEventQueue()

    @test @inferred(isempty(queue))

    @inferred put!(queue, UInt8(2), Int8(0), Int16(5))

    @test @inferred(!isempty(queue))

    @inferred put!(queue, UInt8(1), Int8(1), Int16(8))

    @test @inferred(popfirst!(queue)) == (1, 1, 8)
    @test @inferred(popfirst!(queue)) == (2, 0, 5)
end