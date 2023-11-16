calculate_combinationcount(bounds::AbstractVector{<:Integer}) =
    try
        Base.checked_mul(first(bounds) + 1, mapreduce(i -> (i + 1) * (i + 2) ÷ 2, Base.checked_mul, @view bounds[begin+1:end]))
    catch e
        e isa OverflowError ? typemax(Int) : rethrow()
    end

struct ProductIterator{T}
    iterators::Vector{T}
end

Base.eltype(::Type{ProductIterator{T}}) where {T} = Vector{eltype(T)}
Base.length(iterator::ProductIterator) = prod(length, iterator.iterators)

function Base.iterate(iterator::ProductIterator)
    states = map(iterate, iterator.iterators)
    if any(isnothing, states)
        nothing
    else
        values = map(first, states)
        values, (values, map(last, states))
    end
end
function Base.iterate(iterator::ProductIterator, state::Tuple{<:AbstractVector,<:AbstractVector})
    index = 1
    newvalues = copy(first(state))
    states = last(state)
    while true
        value = iterate(iterator.iterators[index], states[index])
        if value ≡ nothing
            newvalues[index], states[index] = iterate(iterator.iterators[index])
            index += 1
        else
            newvalues[index], states[index] = value
            break
        end
        index > length(iterator.iterators) && (return nothing)
    end
    newvalues, (newvalues, states)
end