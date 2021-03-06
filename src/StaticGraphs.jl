module StaticGraphs

using LightGraphs
using JLD2

import Base:
    convert, eltype, show, ==, Pair, Tuple, in, copy, length, start, next, done, issubset, zero, one,
    size, getindex, setindex!, length, IndexStyle

import LightGraphs:
    _NI, _insert_and_dedup!, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    has_vertex, has_edge, in_neighbors, out_neighbors,
    indegree, outdegree, degree, insorted, squash,

    AbstractGraphFormat, loadgraph, savegraph

import LightGraphs.SimpleGraphs: 
    AbstractSimpleGraph, 
    fadj, 
    badj,
    SimpleEdge,
    AbstractSimpleEdge

export
    AbstractStaticGraph,
    StaticEdge,
    StaticGraph,
    StaticDiGraph,
    StaticDiGraphEdge,
    # weight,
    # weighttype,
    # get_weight,
    out_edges,
    in_edges,
    SGraph,
    SDiGraph,
    SGFormat,
    SDGFormat

include("utils.jl")

const AbstractStaticEdge{T} = AbstractSimpleEdge{T}
const StaticEdge{T} = SimpleEdge{T}

"""
    AbstractStaticGraph

An abstract type representing a simple graph structure.
AbstractStaticGraphs must have the following elements:
- weightmx::AbstractSparseMatrix{Real}
"""
abstract type AbstractStaticGraph{T<:Integer, U<:Integer} <: AbstractSimpleGraph{T} end

vectype(g::AbstractStaticGraph{T, U}) where T where U = T
indtype(g::AbstractStaticGraph{T, U}) where T where U = U
eltype(x::AbstractStaticGraph) = vectype(x)

function show(io::IO, g::AbstractStaticGraph)
    dir = is_directed(g)? "directed" : "undirected"
    print(io, "{$(nv(g)), $(ne(g))} $dir simple static {$(vectype(g)), $(indtype(g))} graph")
end

@inline function _fvrange(g::AbstractStaticGraph, s::Integer)
    @inbounds r_start = g.f_ind[s]
    @inbounds r_end = g.f_ind[s + 1] - 1
    return r_start:r_end
end

@inline function fadj(g::AbstractStaticGraph, s::Integer)
    r = _fvrange(g, s)
    return fastview(g.f_vec, r)
end

nv(g::AbstractStaticGraph{T, U}) where T where U = T(length(g.f_ind) - 1)
vertices(g::AbstractStaticGraph{T, U}) where T where U = one(T):nv(g)


has_edge(g::AbstractStaticGraph, e::AbstractStaticEdge) =
    insorted(dst(e), out_neighbors(g, src(e)))

edgetype(g::AbstractStaticGraph{T}) where T = StaticEdge{T}
edges(g::AbstractStaticGraph) = StaticEdgeIter(g)

has_vertex(g::AbstractStaticGraph, v::Integer) = v in vertices(g)

out_neighbors(g::AbstractStaticGraph, v::Integer) = fadj(g, v)
in_neighbors(g::AbstractStaticGraph, v::Integer) = badj(g, v)

zero(g::T) where T<:AbstractStaticGraph = T()

copy(g::T) where T <: AbstractStaticGraph =  T(copy(g.f_vec), copy(g.f_ind))

const StaticGraphEdge = StaticEdge
const StaticDiGraphEdge = StaticEdge
include("staticgraph.jl")
include("staticdigraph.jl")
include("persistence.jl")

const SGraph = StaticGraph
const SDiGraph = StaticDiGraph

const StaticEdgeIter{G} = LightGraphs.SimpleGraphs.SimpleEdgeIter{G}

eltype(::Type{StaticEdgeIter{StaticGraph{T, U}}}) where T where U = StaticGraphEdge{T}
eltype(::Type{StaticEdgeIter{StaticDiGraph{T, U}}}) where T where U = StaticDiGraphEdge{T}


end # module
