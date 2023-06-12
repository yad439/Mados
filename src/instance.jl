struct Item
    cost::Float32
    central_leadtime::UInt8
    local_leadtimes::Vector{UInt8}
    orders::Vector{Vector{Tuple{UInt8,UInt8}}} # (date, quantity)
end

struct Instance
    items::Vector{Item}
    period::UInt8
end

function validate(instace::Instance)
    @assert instace.period > 0
    @assert length(instace.items) > 0
    @assert all(item.cost > 0.0 for item ∈ instace.items)
    @assert all(item.central_leadtime > 0 for item ∈ instace.items)
    @assert all(length(item.local_leadtimes) == length(item.orders) for item ∈ instace.items)
    @assert all(n > 0 for item ∈ instace.items for unitorders ∈ item.orders for (d, n) ∈ unitorders)
    @assert all(d ∈ 1:instace.period for item ∈ instace.items for unitorders ∈ item.orders for (d, n) ∈ unitorders)
end