# this used to be the worldalive

# TODO: do a constructor that ensures the parameters numerics are of the same type as the agents
mutable struct World{A<:AbstractAgent, S<:AbstractSpacesTuple,T<:Number}
    agents::Vector{AbstractAgentM}
    space::S
    parameters::Dict
    t::T
end

#constructor
function World(w::Vector{A},s::S,p::Dict,t::T=0.) where {A<:AbstractAgent,S<:AbstractSpacesTuple,T}
    if typeof(p["D"]) != eltype(skipmissing(w)[1])
        throw(ArgumentError("Diffusion coefficient does not match with underlying space"))
    end
    ww = vcat(w,repeat([missing],Int(p["NMax"] - length(w))))
    World{A,S,T}(ww,s,p,t)
end

parameters(world::World) = world.parameters
time(w::World) = w.t
space(w::World) = w.space
# this throws indices that are occupied by agents
_get_idx(world::World) = collect(eachindex(skipmissing(world.agents)))
# this throws agents of an abstract array of size size(world)
import Base:size,getindex
Base.size(world::World) = length(world.agents) - count(ismissing,world.agents)
Base.getindex(w::World,i::Int) = w.agents[_get_idx(w)[i]]

# this throws an iterators of agents in the world
agents(world::World) = skipmissing(world.agents)
maxsize(w::World) = w.parameters["NMax"]
_findfreeidx(w::World) = findfirst(ismissing,w.agents)
addAgent!(w::World,a::AbstractAgent) = begin
    idx = _findfreeidx(w)
    w.agents[idx] = a
    return nothing
end
removeAgent!(w::World,i::Int) = begin
    w.agents[_get_idx(w)[i]] = missing
    return nothing
end

update_clock!(w::World{A,S,T},dt) where {A,S,T} = begin
    w.t = convert(T,sum(w.t + dt))
    return nothing
end
