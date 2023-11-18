using JuMP, HiGHS
using LinearAlgebra

function solveknapsack(costs::AbstractVector{<:AbstractVector{<:Real}},
    localsatisfied::AbstractVector{<:AbstractVector{<:Integer}},
    centralsatisfied::AbstractVector{<:AbstractVector{<:Integer}},
    localdemands::AbstractVector{<:Integer},
    centraldemands::AbstractVector{<:AbstractVector{<:Integer}},
    localtarget::Real, centraltarget::Real; silent::Bool=false)

    items = eachindex(costs)
    model = Model(HiGHS.Optimizer)
    silent && set_silent(model)
    @variable(model, x[i ∈ items, eachindex(costs[i])], Bin)
    @objective(model, Min, sum(costs[i] ⋅ x[i, :] for i ∈ items))
    @constraints(model, begin
        [i ∈ items], sum(x[i, :]) == 1
        sum(localsatisfied[i] ⋅ x[i, :] for i ∈ items) ≥ localtarget * sum(localdemands)
        sum(centralsatisfied[i] ⋅ x[i, :] for i ∈ items) ≥ centraltarget * sum(centraldemands[i] ⋅ x[i, :] for i ∈ items)
    end)

    optimize!(model)
    indices = [findfirst(j -> value(x[i, j]) > 0.5, 1:length(costs[i]))::Int for i ∈ items]::Vector{Int}
    objective = objective_value(model)::Float64
    (; objective, indices)
end