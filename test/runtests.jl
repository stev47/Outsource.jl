using Test

using Outsource: Connector, outsource

@testset "Connector" begin
    con = Connector()
    rcon = reverse(con)

    @test isopen(con) && isopen(rcon)

    # input
    x = rand()
    res = @async put!(con, x)
    @test take!(rcon) == x
    @test fetch(res) === con

    # output
    y = rand()
    res = @async put!(rcon, y)
    @test take!(con) == y
    @test fetch(res) === rcon

    @test isnothing(close(con))
    @test !isopen(con) && !isopen(rcon)
end

@testset "outsource" begin
    # TODO: test error handling
end





#
#initialize(param) = rand(1000, 1000) .+ param
#process!(state, in) = state .+= svd(state .+ in).V
#
#
#
#
#workerchannel = outsource(workerid, T, S) do con
#    state = initialize(param)
#    while isopen(con)
#        in = take!(con)::T
#        out = process!(state, in)
#        put!(con, out::S)
#    end
#end
