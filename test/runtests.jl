using Test
using Mados

@testset verbose = true begin
    @testset "Result" include("encoding.jl")
    @testset "Queues" include("queues.jl")
    @testset "Simulator" include("simulator.jl")
end