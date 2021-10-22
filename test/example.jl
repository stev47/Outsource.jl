using Distributed; addprocs(1)
@everywhere using Outsource

# spawn worker
wc = outsource() do c
    state = (0, 1)
    while isopen(c)
        n = take!(c)
        # compute next n Fibonacci numbers
        for _ in 1:n
            state = (state[2], state[1] + state[2])
        end
        put!(c, state[1])
    end
end

# issue stateful work and retrieve result
put!(wc, 10)
take!(wc) # = 55
put!(wc, 10)
take!(wc) # = 6765
