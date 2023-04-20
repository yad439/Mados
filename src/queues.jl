using DataStructures

mutable struct SeparateQueue{V,K}
    queue::PriorityQueue{Tuple{V,UInt16},K} # (value, counter), time
    counter::UInt16
end

SeparateQueue{V,K}() where {V,K} = SeparateQueue{V,K}(PriorityQueue{Tuple{V,UInt16},K}(), 0)

function DataStructures.enqueue!(queue::SeparateQueue{V,K}, time::K, value::V) where {V,K}
    enqueue!(queue.queue, (value, queue.counter), time)
    queue.counter += 1
    nothing
end

function DataStructures.dequeue!(queue::SeparateQueue)
    (value, _), time = peek(queue.queue)
    dequeue!(queue.queue)
    time, value
end

Base.isempty(queue::SeparateQueue) = isempty(queue.queue)

struct StorageEventQueue
    queue::SeparateQueue{Tuple{Int8,Int16},Tuple{UInt8,Bool}} # (destination, quantity) (time, is demand)
end

StorageEventQueue() = StorageEventQueue(SeparateQueue{Tuple{Int8,Int16},Tuple{UInt8,Bool}}())

Base.isempty(queue::StorageEventQueue) = isempty(queue.queue)

function Base.put!(queue::StorageEventQueue, time::UInt8, destination::Int8, quantity::Int16)
    enqueue!(queue.queue, (time, quantity < 0), (destination, quantity))
    nothing
end

function Base.popfirst!(queue::StorageEventQueue)
    (time, _), (destination, quantity) = dequeue!(queue.queue)
    time, destination, quantity
end