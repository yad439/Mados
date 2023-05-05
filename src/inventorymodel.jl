include("abstractmodel.jl")
include("simulator.jl")

struct InventoryModel
    instance::Instance
    target_local::Float64
    target_central::Float64
end

variable_count(model::InventoryModel) = sum(item -> 2length(item.local_leadtimes) + 1, model.instance.items)
fastconstraint_count(model::InventoryModel) = 2sum(item -> length(item.local_leadtimes), model.instance.items)
slowconstraint_count(model::InventoryModel) = 2

struct AgentModel <: AbstractModel
    item::Item
    period::UInt8
    target_local::Float64
    target_central::Float64
    demands::Vector{Int16}
end
AgentModel(item::Item, period::Integer, target_local::AbstractFloat, target_central::AbstractFloat) =
    AgentModel(item, period, target_local, target_central, [sum(r -> r[2], unit) for unit ∈ item.orders])

agentmodels(model::InventoryModel) =
    [AgentModel(item, model.instance.period, model.target_local, model.target_central) for item in model.instance.items]

variable_count(model::AgentModel) = 2length(model.item.local_leadtimes) + 1
fastconstraint_count(model::AgentModel) = 2length(model.item.local_leadtimes)
slowconstraint_count(model::AgentModel) = 2

lowerbounds(::AgentModel, _)::Int16 = 0
upperbounds(model::AgentModel, index::Integer)::Int16 = index == 1 ? sum(model.demands) : model.demands[index÷2]
bounds(model::AgentModel, index::Integer) = (lowerbounds(model, index), upperbounds(model, index))

function fastconstraints(::AgentModel, encoding::Encoding, index::Integer)::Int16
    if !checkindex(Bool, 1:2nlocal(encoding), index)
        throw(BoundsError(1:2nlocal(encoding), index))
    end
    if index <= nlocal(encoding)
        if getinvmax(encoding, index) == 0
            return getinvmin(encoding, index)
        end
        return max(0, getinvmin(encoding, index) - getinvmax(encoding, index) + 1)
    else
        newindex = index - nlocal(encoding)
        if getinvmax(encoding, newindex) ≤ 1
            return 0
        end
        return max(0, getinvmax(encoding, newindex) - 2getinvmin(encoding, newindex))
    end
end

evaluate(model::AgentModel, encoding::Encoding) = simulateone(model.item, model.period, encoding)
objectivevalue(::AgentModel, result::SimulationResult) = cost_local(result) + cost_central(result)
function slowconstraints(model::AgentModel, result::SimulationResult, index::Integer)
    if !checkindex(Bool, 1:2, index)
        throw(BoundsError(1:2, index))
    end
    if index == 1
        return max(0, model.target_local - rate_local(result))
    else
        return max(0, model.target_central - rate_central(result))
    end
end