using StaticGraphs
using LightGraphs
using LightGraphs.SimpleGraphs
using Base.Test

const testdir = dirname(@__FILE__)

    
@testset "StaticGraphs" begin

    h = loadgraph(joinpath(testdir, "testdata", "house.jsg"), SGFormat())
    hu = loadgraph(joinpath(testdir, "testdata", "house-uint8.jsg"), SGFormat(UInt8))
    dh = loadgraph(joinpath(testdir, "testdata", "pathdg.jsg"), SDGFormat())
    dhu = loadgraph(joinpath(testdir, "testdata", "pathdg-uint8.jsg"), SDGFormat(UInt8))

    @testset "staticgraph" begin
        @test sprint(show, StaticGraph(Graph())) == "empty undirected simple static Int64 graph"
        g = smallgraph(:house)
        gu = squash(g)
        sg = StaticGraph(g)
        sgu = StaticGraph(gu)
        @test sprint(show, sg) == "{5, 6} undirected simple static Int64 graph"
        @test sprint(show, sgu) == "{5, 6} undirected simple static UInt8 graph"
        testfn(fn, args...) =
            @inferred(fn(h, args...)) == 
            @inferred(fn(hu, args...)) == 
            @inferred(fn(sg, args...)) == 
            @inferred(fn(sgu, args...)) == 
            fn(g, args...)

        @test h == sg
        @test hu == sgu
        @test @inferred eltype(hu) == UInt8
        @test testfn(ne)
        @test testfn(nv)
        @test testfn(in_neighbors, 1)
        @test testfn(out_neighbors, 1)
        @test testfn(vertices)
        @test testfn(degree)
        @test testfn(degree, 1)
        @test testfn(indegree)
        @test testfn(indegree, 1)
        @test testfn(outdegree)
        @test testfn(outdegree, 1)

        @test @inferred has_edge(hu, 1, 2)
        @test @inferred !has_edge(hu, 1, 5)
        @test @inferred !has_edge(hu, 1, 10)
        @test @inferred has_vertex(hu, 1)
        @test @inferred !has_vertex(hu, 10)
        @test @inferred !is_directed(hu)
        @test @inferred !is_directed(h)
        @test @inferred !is_directed(StaticGraph)
        @test @inferred collect(edges(h)) == collect(edges(sg))
    end # staticgraph

    @testset "staticdigraph" begin
        @test sprint(show, StaticDiGraph(DiGraph())) == "empty directed simple static Int64 graph"
        dg = PathDiGraph(5)
        dgu = squash(dg)
        dsg = StaticDiGraph(dg)
        dsgu = StaticDiGraph(dgu)
        @test sprint(show, dsg) == "{5, 4} directed simple static Int64 graph"
        @test sprint(show, dsgu) == "{5, 4} directed simple static UInt8 graph"
        dh = loadgraph(joinpath(testdir, "testdata", "pathdg.jsg"), SDGFormat())
        dhu = loadgraph(joinpath(testdir, "testdata", "pathdg-uint8.jsg"), SDGFormat(UInt8))

        dtestfn(fn, args...) =
            @inferred(fn(dh, args...)) == 
            @inferred(fn(dhu, args...)) == 
            @inferred(fn(dsg, args...)) == 
            @inferred(fn(dsgu, args...)) == 
            fn(dg, args...)

        @test dh == dsg
        @test dhu == dsgu
        @test @inferred eltype(dhu) == UInt8
        @test dtestfn(ne)
        @test dtestfn(nv)
        @test dtestfn(in_neighbors, 1)
        @test dtestfn(out_neighbors, 1)
        @test dtestfn(vertices)
        @test dtestfn(degree)
        @test dtestfn(degree, 1)
        @test dtestfn(indegree)
        @test dtestfn(indegree, 1)
        @test dtestfn(outdegree)
        @test dtestfn(outdegree, 1)

        @test @inferred has_edge(dhu, 1, 2)
        @test @inferred !has_edge(dhu, 2, 1)
        @test @inferred !has_edge(dhu, 1, 10)
        @test @inferred has_vertex(dhu, 1)
        @test @inferred !has_vertex(dhu, 10)
        @test @inferred is_directed(dhu)
        @test @inferred is_directed(dh)
        @test @inferred is_directed(StaticDiGraph)
        @test @inferred collect(edges(dh)) == collect(edges(dsg))
    end # staticdigraph

    @testset "utils" begin
        A = [1:5;]
        B = StaticGraphs.fastview(A, 2:3)
        @test @inferred B == [2,3]
        B[1] = 5
        @test @inferred A == [1,5,3,4,5]
        A = ["a", "b", "c", "d"]
        @test @inferred StaticGraphs.fastview(A, 2:3) == ["b", "c"]
    end # utils

    @testset "persistence" begin
        function writegraphs(f, fio)
            @test savegraph(f, h) == 1
            @test savegraph(f, hu) == 1
            @test savegraph(f, dh) == 1
            @test savegraph(f, dhu) == 1
        end
        mktemp(writegraphs)
    end

end # StaticGraphs