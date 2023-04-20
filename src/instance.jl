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