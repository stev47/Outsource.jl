module Outsource

export outsource

include("connector.jl")

using Distributed: remote_do, workers, myid, remotecall_eval

"""
    outsource(f, id)
    outsource(f, id, T, S)

Remotely issue a processing function `f` to run on worker `id`, optionally
specifying input and output type `T` and `S` respectively.
Returns a `Connector{S,T}` that allows `put!()`ing input data of type `T` and
`take!()`ing output data of type `S`.
The processing function `f` is being called with a `Connector{T,S}` that allows
`take!()`ing input data of type `T` and `put!()`ing output data of type `S`.
Exceptions thrown in `f` are logged as errors in the current task.
"""
outsource(f, id = rand(workers())) = outsource(f, id, Any, Any)
function outsource(f, id, ::Type{T}, ::Type{S}) where {T,S}
    myid() == 1 || @error("need to be called from pid 1")
    id != myid() || @warn("outsourcing to task on same process" *
        " (no parallel execution)", maxlog = 1)

    con = Connector{S, T}()
    rcon = reverse(con)

    # hack to ensure `f` is defined remotely
    # otherwise we get an uncatchable exception that gets hidden
    remotecall_eval(Main, id, f)
    remote_do(id) do
        try
            f(rcon)
        catch e
            # TODO: for non-shared stdout, exceptions need to be
            #       communicated back. Maybe introduce a global pid1
            #       remote-channel for that
            # TODO: prune serialization stuff from stacktrace
            @error(
                "outsourced task failed",
                exception = (e, catch_backtrace()))
        finally
            close(rcon)
        end
    end
    return con
end

end # module
