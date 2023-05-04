include("abstractmodel.jl")

struct SlowPenaltiedModel{M<:AbstractModel} <: AbstractModel
    model::M
    penalty::Float64
end
variable_count(model::SlowPenaltiedModel) = variable_count(model.model)

lowerbounds(model::SlowPenaltiedModel) = lowerbounds(model.model)
lowerbounds(model::SlowPenaltiedModel, index) = lowerbounds(model.model, index)
upperbounds(model::SlowPenaltiedModel) = upperbounds(model.model)
upperbounds(model::SlowPenaltiedModel, index) = upperbounds(model.model, index)
bounds(model::SlowPenaltiedModel) = bounds(model.model)
bounds(model::SlowPenaltiedModel, index) = bounds(model.model, index)

fastconstraint_count(model::SlowPenaltiedModel) = fastconstraint_count(model.model)
fastconstraints(model::SlowPenaltiedModel, encoding) = fastconstraints(model.model, encoding)
fastconstraints(model::SlowPenaltiedModel, encoding, index) = fastconstraints(model.model, encoding, index)
fastconstraints_sum(model::SlowPenaltiedModel, encoding) = fastconstraints_sum(model.model, encoding)

slowconstraint_count(model::SlowPenaltiedModel) = 0

function evaluate(model::SlowPenaltiedModel, encoding)
    @assert fastconstraints_sum(model.model, encoding) == 0
    result = evaluate(model.model, encoding)
    objective = objectivevalue(model.model, result)

    objective + model.penalty * slowconstraints_sum(model.model, result)
end

mutable struct CountingModel{M<:AbstractModel} <: AbstractModel
    model::M
    evaluations::Int
end
CountingModel(model::AbstractModel) = CountingModel(model, 0)
evaluation_count(model::CountingModel) = model.evaluations

variable_count(model::CountingModel) = variable_count(model.model)
lowerbounds(model::CountingModel) = lowerbounds(model.model)
lowerbounds(model::CountingModel, index) = lowerbounds(model.model, index)
upperbounds(model::CountingModel) = upperbounds(model.model)
upperbounds(model::CountingModel, index) = upperbounds(model.model, index)
bounds(model::CountingModel) = bounds(model.model)
bounds(model::CountingModel, index) = bounds(model.model, index)
fastconstraint_count(model::CountingModel) = fastconstraint_count(model.model)
fastconstraints(model::CountingModel, encoding) = fastconstraints(model.model, encoding)
fastconstraints(model::CountingModel, encoding, index) = fastconstraints(model.model, encoding, index)
fastconstraints_sum(model::CountingModel, encoding) = fastconstraints_sum(model.model, encoding)
slowconstraint_count(model::CountingModel) = slowconstraint_count(model.model)
evaluate(model::CountingModel, encoding) = (model.evaluations += 1; evaluate(model.model, encoding))
objectivevalue(model::CountingModel, result) = objectivevalue(model.model, result)
slowconstraints(model::CountingModel, result) = slowconstraints(model.model, result)
slowconstraints(model::CountingModel, result, index) = slowconstraints(model.model, result, index)
slowconstraints_sum(model::CountingModel, result) = slowconstraints_sum(model.model, result)