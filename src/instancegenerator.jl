using Distributions

include("instance.jl")

function generateorders(planningperiod::Integer, λ::AbstractFloat)
    dist = Poisson(λ)

    [(d, n) for (d, n) ∈ enumerate(rand(dist, planningperiod)) if n ≠ 0]
end

function generateitem(unitcount::Int, planningperiod::Int, λ::Float64, ρ::Float64, λₘ::Float64,
    c₀::Float64, ρc::Float64, cₘ::Float64, centraltime_dist, localtimes_dist)
    ν = max(λ / ρ * rand(Float64)^((1 - ρ) / ρ), λₘ)
    orders = Iterators.filter(!isempty, (generateorders(planningperiod, ν * 2rand(Float64)) for _ = 1:unitcount)) |> collect
    if isempty(orders)
        @warn "No orders generated for item"
        return nothing
    end
    central_leadtime = rand(centraltime_dist)
    local_leadtimes = rand(localtimes_dist, length(orders))
    cost = max(c₀ / ρc * rand(Float64)^((1 - ρc) / ρc), cₘ)

    Item(cost, central_leadtime, local_leadtimes, orders)
end

function generateinstance(itemcount::Int, unitcount::Int, planningperiod::Int, demand_mean::Float64,
    demand_skewness::Float64, demand_min::Float64, cost_mean::Float64, cost_skewness::Float64, cost_min::Float64,
    centraltime_dist, localtimes_dist)
    items = Iterators.filter(!isnothing, generateitem(unitcount, planningperiod, demand_mean, demand_skewness,
        demand_min, cost_mean, cost_skewness, cost_min, centraltime_dist, localtimes_dist) for _ = 1:itemcount) |> collect
    Instance(items, planningperiod)
end