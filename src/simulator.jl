include("instance.jl")
include("encoding.jl")
include("queues.jl")

using DataStructures

function simulateall(instance::Instance, policies::AbstractVector{Encoding})
    @assert length(policies) == length(instance.items)
    itemresults = map((item, encoding) -> simulateone(item, instance.period, encoding), instance.items, policies)
    localcost = sum(cost_local, itemresults)
    centralcost = sum(cost_central, itemresults)
    localdemand = sum(demand_local, itemresults)
    centraldemand = sum(demand_central, itemresults)
    localsatisfied = sum(satisfied_local, itemresults)
    centralsatisfied = sum(satisfied_central, itemresults)

    SimulationResult(localcost, centralcost, localdemand, centraldemand, localsatisfied, centralsatisfied)
end

function simulateone(item::Item, period::Integer, policies::Encoding)
    @assert nlocal(policies) == length(item.local_leadtimes)
    localstocks = policies.encoding[3:2:end]
    centralstock = getrop(policies)
    locallevels = copy(localstocks)
    eventqueue = StorageEventQueue()
    localpromises = zeros(Int16, length(localstocks))
    centralpromises = Deque{Tuple{Int8,Int16}}() # (unit, quantity)
    localdemand = 0
    unsatlocal = 0
    centraldemand = 0
    unsatcentral = 0
    for (i, unit) ∈ enumerate(item.orders)
        for (date, quantity) ∈ unit
            put!(eventqueue, date, Int8(i), -Int16(quantity))
        end
    end
    localcost = 0
    centralcost = 0
    previousdate = 1
    while !isempty(eventqueue)
        date, destination, quantity = popfirst!(eventqueue)
        @assert quantity ≠ 0
        date ≤ period || break
        if date ≠ previousdate
            localcost += sum(localstocks) * item.cost * (date - previousdate)
            centralcost += centralstock * item.cost * (date - previousdate)
            previousdate = Int(date)
        end
        if destination == 0
            @assert quantity > 0
            while quantity ≠ 0 && !isempty(centralpromises)
                @assert centralstock == 0
                unit, request = popfirst!(centralpromises)
                if request ≤ quantity
                    put!(eventqueue, date + item.local_leadtimes[unit], unit, request)
                    quantity -= request
                else
                    put!(eventqueue, date + item.local_leadtimes[unit], unit, quantity)
                    pushfirst!(centralpromises, (unit, request - quantity))
                    quantity = 0
                end
            end
            centralstock += quantity
        else
            if quantity > 0
                asdept = min(quantity, localpromises[destination])
                localpromises[destination] -= asdept
                quantity -= asdept
                localstocks[destination] += quantity
            else
                demand = -quantity
                localdemand += demand
                satisfied = min(demand, localstocks[destination])
                localstocks[destination] -= satisfied
                unsatlocal += demand - satisfied
                localpromises[destination] += demand - satisfied
                locallevels[destination] -= demand
                if locallevels[destination] ≤ getinvmin(policies, destination)
                    replenishment_request = getinvmax(policies, destination) - locallevels[destination]
                    centraldemand += replenishment_request
                    replenishment_count = Int16(min(replenishment_request, centralstock))
                    centralstock -= replenishment_count
                    unsatcentral += replenishment_request - replenishment_count
                    replenishment_request ≠ replenishment_count && push!(centralpromises, (destination, replenishment_request - replenishment_count))
                    replenishment_count ≠ 0 && put!(eventqueue, date + item.local_leadtimes[destination], destination, replenishment_count)
                    put!(eventqueue, date + item.central_leadtime, Int8(0), replenishment_request)
                    locallevels[destination] += replenishment_request
                end
            end
        end
    end
    localcost += sum(localstocks) * item.cost * (period - previousdate + 1)
    centralcost += centralstock * item.cost * (period - previousdate + 1)

    SimulationResult(localcost, centralcost, localdemand, centraldemand, localdemand - unsatlocal, centraldemand - unsatcentral)
end