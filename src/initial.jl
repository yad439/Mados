include("inventorymodel.jl")


function testmin(model::AgentModel, encoding::Encoding, index::Integer, value::Integer)::Bool
    previous = getinvmin(encoding, index)
    setinvmin!(encoding, index, value)
    result = evaluate(model, encoding)
    setinvmin!(encoding, index, previous)

    unsatisfied_local(result) == 0
end

function testmax(model::AgentModel, encoding::Encoding, index::Integer, value::Integer)::Bool
    previous = getinvmax(encoding, index)
    setinvmax!(encoding, index, value)
    result = _binarysearch(v -> testmin(model, encoding, index, v), 0, model.demands[index]) - 1
    setinvmax!(encoding, index, previous)
    print(result)

    result ≠ model.demands[index] + 1
end

function testrop(model::AgentModel, encoding::Encoding, value::Integer)::Bool
    previous = getrop(encoding)
    setrop!(encoding, value)
    result = evaluate(model, encoding)
    setrop!(encoding, previous)

    unsatisfied_central(result) == 0
end

function find_localparams(model::AgentModel, encoding::Encoding, index::Integer)::Tuple{Int,Int}
    invmax = _binarysearch(v -> testmax(model, encoding, index, v), 0, model.demands[index]) - 1
    previous = getinvmax(encoding, index)
    setinvmax!(encoding, index, invmax)
    invmin = _binarysearch(v -> testmin(model, encoding, index, v), 0, model.demands[index]) - 1
    setinvmax!(encoding, index, previous)

    invmin, invmax
end

function find_rop(model::AgentModel, encoding::Encoding)::Int
    _binarysearch(v -> testrop(model, encoding, v), 0, sum(model.demands)) - 1
end

function find_feasibleprapameters(model::AgentModel)::Encoding
    encoding = Encoding(zeros(Int16, variable_count(model)))
    setrop!(encoding, sum(model.demands))
    for i ∈ 1:nlocal(encoding)
        params = find_localparams(model, encoding, i)
        setinvmin!(encoding, i, first(params))
        setinvmax!(encoding, i, last(params))
    end
    setrop!(encoding, find_rop(model, encoding))
    encoding
end

function _binarysearch(f, min, max)
    f(max) || return 0
    while min < max
        if f((min + max) ÷ 2)
            max = (min + max) ÷ 2
        else
            min = (min + max) ÷ 2 + 1
        end
    end
    min
end