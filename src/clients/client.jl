# Copyright (c) 2025 Fenyutanchan <fenyutanchan@gmail.com>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

abstract type AbstractClient end
export AbstractClient

__URL(c::AbstractClient) = c.URL
__API_key(c::AbstractClient) = c.API_key
__model(c::AbstractClient) = c.model
__timeout(c::AbstractClient) = c.timeout

__build_URL(c::AbstractClient, endpoint::String) = joinpath(__URL(c), endpoint)
function __build_headers!(::Type{AbstractClient}, c::AbstractClient; headers::Dict{String,String}=Dict{String,String}())
    if !haskey(headers, "Content-Type")
        headers["Content-Type"] = "application/json"
    end
    __auth_headers!(c, headers)
    return headers
end
function __auth_headers! end

function get_model_list end
export get_model_list

# built-in clients
include("POE_client.jl")
