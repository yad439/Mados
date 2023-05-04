using Mados: AbstractModel, SlowPenaltiedModel, CountingModel, variable_count, fastconstraint_count, fastconstraints,
    fastconstraints_sum, slowconstraint_count, evaluate, objectivevalue, slowconstraints, slowconstraints_sum,
    evaluation_count, lowerbounds, upperbounds, bounds

struct TestModel <: AbstractModel
    nvar::Int
    lowerbounds::Vector{Int}
    upperbounds::Vector{Int}
    objective::Function
    fast::Vector{Function}
    slow::Vector{Function}
end

Mados.variable_count(model::TestModel) = model.nvar
Mados.bounds(model::TestModel, i::Integer) = model.lowerbounds[i], model.upperbounds[i]
Mados.fastconstraint_count(model::TestModel) = length(model.fast)
Mados.fastconstraints(model::TestModel, encoding, i::Integer) = model.fast[i](encoding)::Int
Mados.slowconstraint_count(model::TestModel) = length(model.slow)

struct TestResult
    obj::Int
    constraints::Vector{Int}
end

Mados.evaluate(model::TestModel, encoding) = TestResult(model.objective(encoding), [f(encoding) for f in model.slow])
Mados.objectivevalue(::TestModel, result::TestResult) = result.obj
Mados.slowconstraints(::TestModel, result::TestResult, i::Integer) = result.constraints[i]

@testset "Slow penaltied model" begin
    model = TestModel(2, [-10, -11], [10, 11], x -> x[1]^2 + x[2]^2, [x -> max(-x[1], 0), x -> max(-x[2], 0)], [x -> max(x[1] - x[2], 0)])
    penaltied = SlowPenaltiedModel(model, 7.0)

    @test @inferred(variable_count(penaltied)) == 2
    @test @inferred(lowerbounds(penaltied)) == [-10, -11]
    @test @inferred(upperbounds(penaltied)) == [10, 11]
    @test @inferred(bounds(penaltied)) == [(-10, 10), (-11, 11)]

    @test @inferred(fastconstraint_count(penaltied)) == 2
    @test @inferred(slowconstraint_count(penaltied)) == 0
    @test @inferred(fastconstraints(penaltied, [1, 2])) == [0, 0]
    @test @inferred(fastconstraints_sum(penaltied, [1, 2])) == 0

    @test @inferred(fastconstraints(penaltied, [-1, -2], 1)) == 1
    @test @inferred(fastconstraints(penaltied, [-1, -2], 2)) == 2
    @test @inferred(fastconstraints(penaltied, [-1, -2])) == [1, 2]
    @test @inferred(fastconstraints_sum(penaltied, [-1, -2])) == 3

    result1 = @inferred evaluate(penaltied, [2, 2])
    @test @inferred(objectivevalue(penaltied, result1)) == 8
    @test @inferred(slowconstraints_sum(penaltied, result1)) == 0
    result2 = @inferred evaluate(penaltied, [3, 2])
    @test @inferred(objectivevalue(penaltied, result2)) == 3^2 + 2^2 + 7 * 1
    @test @inferred(slowconstraints_sum(penaltied, result2)) == 0
end
@testset "Counting model" begin
    model = TestModel(2, [-10, -11], [10, 11], x -> x[1]^2 + x[2]^2, [x -> max(-x[1], 0), x -> max(-x[2], 0)], [x -> max(x[1] - x[2], 0)])
    counting = CountingModel(model)

    @test @inferred(variable_count(counting)) == 2
    @test @inferred(lowerbounds(counting)) == [-10, -11]
    @test @inferred(upperbounds(counting)) == [10, 11]
    @test @inferred(bounds(counting)) == [(-10, 10), (-11, 11)]

    @test @inferred(fastconstraint_count(counting)) == 2
    @test @inferred(slowconstraint_count(counting)) == 1
    @test @inferred(fastconstraints(counting, [1, 2])) == [0, 0]
    @test @inferred(fastconstraints_sum(counting, [1, 2])) == 0

    @test @inferred(fastconstraints(counting, [-1, -2], 1)) == 1
    @test @inferred(fastconstraints(counting, [-1, -2], 2)) == 2
    @test @inferred(fastconstraints(counting, [-1, -2])) == [1, 2]
    @test @inferred(fastconstraints_sum(counting, [-1, -2])) == 3

    result1 = @inferred evaluate(counting, [2, 2])
    @test @inferred(objectivevalue(counting, result1)) == 8
    @test @inferred(slowconstraints(counting, result1, 1)) == 0
    @test @inferred(slowconstraints(counting, result1)) == [0]
    @test @inferred(slowconstraints_sum(counting, result1)) == 0
    @test @inferred(evaluation_count(counting)) == 1

    result2 = @inferred evaluate(counting, [3, 2])
    @test @inferred(objectivevalue(counting, result2)) == 3^2 + 2^2
    @test @inferred(slowconstraints(counting, result2, 1)) == 1
    @test @inferred(slowconstraints(counting, result2)) == [1]
    @test @inferred(slowconstraints_sum(counting, result2)) == 1
    @test @inferred(evaluation_count(counting)) == 2
end