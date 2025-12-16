# Copyright (c) 2025 Fenyutanchan <fenyutanchan@gmail.com>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

using FytcAgents
using Test

if isfile("secrets.jl")
    include("secrets.jl")
else
    @warn "The file `secrets.jl` not found, get API keys from `ARGS`."
    @warn "The argument in `ARGS` are expected to be in the format of `KEY=VALUE`."
    for arg ∈ ARGS
        key, value = split(arg, '=')
        ENV[key] = value
        @info "Get `$(key)` from `ARGS`."
    end
end

include("POE_test.jl")
