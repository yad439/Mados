abstract type AbstractModel end

"""
	varaible_count(model::AbstractModel)::Int
"""
function variable_count end

"""
	constraint_count(model::AbstractModel)::Int
"""
function fastconstraint_count end

"""
	constraint_count(model::AbstractModel)::Int
"""
function slowconstraint_count end

"""
	evaluate(model::AbstractModel, encoding)
"""
function evaluate end

"""
	objectivevalue(model::AbstractModel, result)::Real
"""
function objectivevalue end

"""
	fastconstraints(model::AbstractModel, encoding)::Vector{<:Real}
"""
function fastconstraints end

"""
	fastconstraints(model::AbstractModel, encoding, index)::Real
"""
function fastconstraints end

"""
	fastconstraints_sum(model::AbstractModel, encoding)::Real
"""
function fastconstraints_sum end

"""
	slowconstraints(model::AbstractModel, result)::Vector{<:Real}
"""
function slowconstraints end

"""
	slowconstraints(model::AbstractModel, result, index)::Real
"""
function slowconstraints end

"""
	slowconstraints_sum(model::AbstractModel, result)::Real
"""
function slowconstraints_sum end