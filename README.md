# Outsource

Simple and explicit asychronous handling of stateful worker tasks in a Julia
distributed computing environment.

  - central spawning of workers
  - communication through bidirectional channel-like interface
  - remote exceptions are thrown locally as errors

# Examples

```julia
using Distributed; addprocs(1)
@everywhere using Outsource

# spawn to worker id 2
wc = outsource(2) do c
  while isopen(c)
    x = take!(c)
    put!(c, x + 1)
  end
end

put!(wc, 1); take!(wc) # == 2
put!(wc, 3); take!(wc) # == 4
```
