using Test
using Mados

@testset verbose = true begin
    @testset "Result" include("encoding.jl")
    @testset "Queues" include("queues.jl")
    @testset "Simulator" include("simulator.jl")
    @testset "Model extensions" include("modelextensions.jl")
    @testset "Inventory model" include("inventorymodel.jl")
end