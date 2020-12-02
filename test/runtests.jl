using Test

using Distributed
addprocs(1)

using Logging: NullLogger, with_logger
silence(f) = with_logger(f, NullLogger())

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

f() = nothing
@testset "outsource" begin
    silence() do
        con = outsource(_ -> nothing, 1)
        @test isa(con, Connector)
    end
    @test_throws Exception outsource(f, 2)
    # TODO: test async remote error handling
end
