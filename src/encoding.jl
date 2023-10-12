struct Encoding
    encoding::Vector{Int16} # [rop, invmin1, invmax1, invmin2, invmax2, ...]
end

getrop(policies::Encoding) = policies.encoding[1]
getinvmin(policies::Encoding, i::Integer) = policies.encoding[2*i]
getinvmax(policies::Encoding, i::Integer) = policies.encoding[2*i+1]
nlocal(policies::Encoding) = (length(policies.encoding) - 1) ÷ 2

setrop!(policies::Encoding, value::Integer) = (policies.encoding[1] = value; nothing)
setinvmin!(policies::Encoding, i::Integer, value::Integer) = (policies.encoding[2*i] = value; nothing)
setinvmax!(policies::Encoding, i::Integer, value::Integer) = (policies.encoding[2*i+1] = value; nothing)

struct SimulationResult
    cost_local::Float64
    cost_central::Float64
    demand_local::Int16
    demand_central::Int16
    satisfied_local::Int16
    satisfied_central::Int16
end

cost_local(r::SimulationResult) = r.cost_local
cost_central(r::SimulationResult) = r.cost_central
demand_local(r::SimulationResult) = r.demand_local
demand_central(r::SimulationResult) = r.demand_central
satisfied_local(r::SimulationResult) = r.satisfied_local
satisfied_central(r::SimulationResult) = r.satisfied_central
unsatisfied_local(r::SimulationResult) = r.demand_local - r.satisfied_local
unsatisfied_central(r::SimulationResult) = r.demand_central - r.satisfied_central
rate_local(r::SimulationResult) = r.demand_local ≠ 0 ? r.satisfied_local // r.demand_local : Rational{Int16}(1)
rate_central(r::SimulationResult) = r.demand_central ≠ 0 ? r.satisfied_central // r.demand_central : Rational{Int16}(1)