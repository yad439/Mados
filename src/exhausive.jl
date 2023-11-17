include("inventorymodel.jl")

function generate_allcombinations(model::AgentModel)
    n = (variable_count(model) - 1) ÷ 2
    bounds = upperbounds(model)[2:2:end]
    @assert length(bounds) == n
    values = Vector{Vector{Tuple{Int16,Int16}}}(undef, n + 1)
    values[1] = [(Int16(i), Int16(i)) for i = 0:upperbounds(model, 1)]
    for i = 1:n
        values[i+1] = [(Int16(k), Int16(j)) for j = 0:bounds[i] for k = 0:j]
    end
    Iterators.map(Encoding ∘ _concatencoding, ProductIterator(values))
end

function _concatencoding(parts::AbstractVector{Tuple{T,T}}) where {T<:Integer}
    result = Vector{T}(undef, 2 * length(parts) - 1)
    result[1] = parts[1][1]
    for i = 2:length(parts)
        result[2(i-1)] = parts[i][1]
        result[2i-1] = parts[i][2]
    end
    result
end

calculate_combinationcount(demands::AbstractVector{<:Integer}) =
    try
        Base.checked_mul(sum(demands) + 1, mapreduce(i -> (i + 1) * (i + 2) ÷ 2, Base.checked_mul, demands))
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
        copy(values), (values, map(last, states))
    end
end
function Base.iterate(iterator::ProductIterator, state::Tuple{<:AbstractVector,<:AbstractVector})
    index = 1
    values = first(state)
    states = last(state)
    while true
        value = iterate(iterator.iterators[index], states[index])
        if value ≡ nothing
            values[index], states[index] = iterate(iterator.iterators[index])
            index += 1
        else
            values[index], states[index] = value
            break
        end
        index > length(iterator.iterators) && (return nothing)
    end
    copy(values), (values, states)
end