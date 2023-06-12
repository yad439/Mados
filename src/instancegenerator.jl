using Distributions

include("instance.jl")

function generateorders(planningperiod::Integer, λ::AbstractFloat)
    dist = Poisson(λ)

    [(d, n) for (d, n) ∈ enumerate(rand(dist, planningperiod)) if n ≠ 0]
end

function generateitem(unitcount::Int, planningperiod::Int, λ::Float64, ρ::Float64, c₀::Float64, ρc::Float64, centraltime_dist, localtimes_dist)
    ν = λ / ρ * rand(Float64)^((1 - ρ) / ρ)
    orders = Iterators.filter(!isempty, (generateorders(planningperiod, ν * 2rand(Float64)) for _ = 1:unitcount)) |> collect
    central_leadtime = rand(centraltime_dist)
    local_leadtimes = rand(localtimes_dist, length(orders))
    cost = c₀ / ρc * rand(Float64)^((1 - ρc) / ρc)

    Item(cost, central_leadtime, local_leadtimes, orders)
end

function generateinstance(itemcount::Int, unitcount::Int, planningperiod::Int, λ::Float64, ρ::Float64, c₀::Float64, ρc::Float64, centraltime_dist, localtimes_dist)
    items = [generateitem(unitcount, planningperiod, λ, ρ, c₀, ρc, centraltime_dist, localtimes_dist) for _ = 1:itemcount]
    Instance(items, planningperiod)
end