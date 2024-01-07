using Distributed: RemoteChannel

"""
    Connector{T, S}

A channel-like interface that accepts objects of type `T` (through `put!`) and
may provide objects of type `S` (through `take!`).
"""
struct Connector{T, S}
    outwards::RemoteChannel{Channel{T}}
    inwards::RemoteChannel{Channel{S}}
end

Connector(;proc = 1) = Connector{Any, Any}(;proc)
Connector{T, S}(;proc = 1) where {T, S} =
    Connector(
        RemoteChannel(() -> Channel{T}(0), proc),
        RemoteChannel(() -> Channel{S}(0), proc))

Base.show(io::IO, ::MIME"text/plain", con::Connector{T,S}) where {T,S} =
    print(io, "Connector: $T to $S, ", isopen(con) ? "open" : "closed")

# channel-like interface
Base.put!(con::Connector{T}, x::T) where T = (put!(con.outwards, x); con)
Base.take!(con::Connector) = take!(con.inwards)
Base.close(con::Connector) = (close(con.outwards); close(con.inwards); nothing)
Base.isopen(con::Connector) = isopen(con.outwards) && isopen(con.inwards)

"""
    reverse(::Connector)

Obtain the other matching end of the connector pair.
"""
Base.reverse(con::Connector) = Connector(con.inwards, con.outwards)
