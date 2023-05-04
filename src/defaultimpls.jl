include("abstractmodel.jl")

lowerbounds(model::AbstractModel) = [lowerbounds(model, i) for i in 1:variable_count(model)]
upperbounds(model::AbstractModel) = [upperbounds(model, i) for i in 1:variable_count(model)]
bounds(model::AbstractModel) = [bounds(model, i) for i in 1:variable_count(model)]
lowerbounds(model::AbstractModel, index) = bounds(model, index)[1]
upperbounds(model::AbstractModel, index) = bounds(model, index)[2]

objectivevalue(::AbstractModel, result::Real) = result
slowconstraints_sum(::AbstractModel, result::Real) = 0

fastconstraints(model::AbstractModel, encoding) = [fastconstraints(model, encoding, i) for i in 1:fastconstraint_count(model)]
fastconstraints_sum(model::AbstractModel, encoding) = sum(fastconstraints(model, encoding, i) for i in 1:fastconstraint_count(model))

slowconstraints(model::AbstractModel, result) = [slowconstraints(model, result, i) for i in 1:slowconstraint_count(model)]
slowconstraints_sum(model::AbstractModel, result) = sum(slowconstraints(model, result, i) for i in 1:slowconstraint_count(model))