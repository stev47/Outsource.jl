using Distributed: RemoteChannel

"""
    Connector{T, S}

A channel-like interface that accepts objects of type `T` (through `put!`) and
may provide objects of type `S` (through `take!`).
"""
struct Connector{T, S}
    a::RemoteChannel{Channel{T}}
    b::RemoteChannel{Channel{S}}
end

Connector(;proc = 1) = Connector{Any, Any}(;proc)
Connector{T, S}(;proc = 1) where {T, S} =
    Connector(
        RemoteChannel(() -> Channel{T}(0), proc),
        RemoteChannel(() -> Channel{S}(0), proc))

Base.show(io::IO, ::MIME"text/plain", con::Connector{T,S}) where {T,S} =
    print(io, "Connector: $T to $S, ", isopen(con) ? "open" : "closed")

# channel-like interface
Base.put!(con::Connector{T}, x::T) where T = (put!(con.a, x); con)
Base.take!(con::Connector) = take!(con.b)
Base.close(con::Connector) = (close(con.a); close(con.b); nothing)
Base.isopen(con::Connector) = isopen(con.a) && isopen(con.b)

"""
    reverse(::Connector)

Obtain the other matching end of the connector pair.
"""
Base.reverse(con::Connector) = Connector(con.b, con.a)
