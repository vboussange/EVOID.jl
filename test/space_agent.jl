using LightGraphs
using Test
using Revise,ABMEv

##### SPACES #####
mysegment = DiscreteSegment(1,10)
mygraph = GraphSpace(SimpleGraph(10,10))
real2d = RealSpace{2,Float64}()
myline = RealSpace{1,Float16}()
mydiscreteline = NaturalSpace{1,Int8}()
mycontinuoussegment = ContinuousSegment(-1.,1.)
myspace = (mysegment,mygraph,myline)
myspace2 = (mysegment,mycontinuoussegment,real2d)

@testset "Space properties" begin
    # checking essential properties of spaces
    @test isfinite(mysegment) ≈ true
    @test isfinite(mygraph) ≈ true
    @test isfinite(myline) ≈ false
    @test ndims(real2d) ≈ 2
    @test isfinite(mycontinuoussegment) ≈ true
    @test typeof(myspace) <: AbstractSpacesTuple
    @test eltype(myspace2) == Tuple{Int64,Float64,Tuple{Float64,Float64}}

    # increment on infinite spaces
    @test ABMEv.get_inc(0.,myline) ≈ (0.)
    @test ABMEv.get_inc(0.,mydiscreteline) ≈ (0.)
    @test !(ABMEv.get_inc(1.,myline) ≈ 0.)
    @test !(get_inc(1,1.,myline) ≈ 0.)
    @test !(get_inc(1,1.,mydiscreteline) ≈ 0.)


    @test typeof(ABMEv.get_inc([1.,0.],real2d)) == Tuple{Float64,Float64}
    @test typeof(get_inc([1.,0.],[1.,0.],real2d)) == Tuple{Float64,Float64}
    @test typeof(ABMEv.get_inc([1.],real2d)) == Tuple{Float64,Float64}
    @test typeof(ABMEv.get_inc(1.,real2d)) == Tuple{Float64,Float64}
    # ABMEv._get_inc([1.],real2d)
    # ABMEv.initpos(myspace2)


    # increment on finite spaces
    # checking if reflection works
    @testset "Reflection" begin
        @test mysegment.s - eps() < get_inc(5.,100.,mysegment) + 5. < mysegment.e + eps()
        @test mycontinuoussegment.s < get_inc(0.,100.,mycontinuoussegment) < mycontinuoussegment.e
        mysegment2 = DiscreteSegment(-1,1)
        @test ABMEv._reflect1D(0.,2.0,mysegment2) ≈ .0
        @test ABMEv._reflect1D(0.,-2.0,mysegment2) ≈ .0
        @test ABMEv._reflect1D(0.,4.0,mysegment2) ≈ .0
        @test ABMEv._reflect1D(0.,1.1,mysegment2) ≈ 1 - .1
    end

    #checking if graph works
    @test prod([get_inc(1,10,mygraph) + 1 ∈ vertices(mygraph.g) for i in 1:30])
end

##### AGENTS #######
a1 = Agent(myspace)
a2 = Agent(myspace,ancestors = true)
a3 = Agent(myspace,(1,1,1.))
a4 = Agent(myspace2,(1,1,(1.,1)),rates=true)
a5 = Agent(myspace2,ancestors=true)

@testset "Agent properties" begin
    # basic test
    @test typeof(a1) <: AbstractAgent
    @test eltype(a1) == eltype(myspace)
    @test eltype(a5) == eltype(myspace2)
    @test typeof(a1) <: AbstractAgent

    # increment test
    p_myspace = Dict("D"=>[1,1,1],"mu" =>[1,1,1] )
    p_myspace2 = Dict("D"=>[1,1,1],"mu" =>[1,1,1])
    old_a1 = copy(a1)
    @test !prod((get_x(old_a1) .≈ get_x(increment_x!(a1,myspace,p_myspace,0.))))
    @test nancestors(increment_x!(a2,myspace,p_myspace,2.)) > 1
    @test !isnothing(increment_x!(a4,myspace2,p_myspace2,2.))
    @test !isnothing(increment_x!(a5,myspace2,p_myspace2,2.))
end