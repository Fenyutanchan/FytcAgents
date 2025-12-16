# Copyright (c) 2025 Fenyutanchan <fenyutanchan@gmail.com>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

export POEClient
export POE_chat_completion

Base.@kwdef struct POEClient <: AbstractClient
    API_key::String = ""
    model::String = ""
    timeout::Int = 60 # in seconds
end
__URL(c::POEClient) = "https://api.poe.com/v1"

__build_URL(c::POEClient, endpoint::String) = joinpath(__URL(c), endpoint)

function __build_headers!(::Type{POEClient}, c::POEClient; headers::Dict{String,String}=Dict{String,String}())
    __build_headers!(AbstractClient, c; headers=headers)
    if !haskey(headers, "Accept")
        headers["Accept"] = "application/json"
    end
    return headers
end
function __auth_headers!(c::POEClient, headers::Dict{String,String})
    headers["Authorization"] = "Bearer $(__API_key(c))"
end

function get_model_list(c::POEClient; return_json=false)
    url = __build_URL(c, "models")
    headers = __build_headers!(POEClient, c)
    response = HTTP.get(url; headers=headers, connect_timeout=__timeout(c))

    response_body = JSON.parse(String(response.body))
    return_json && return response_body

    model_id_list = String[data["id"] for data ∈ response_body["data"]]
    return model_id_list
end

export POE_chat_completion
POE_chat_completion(c::POEClient, user_content::String; kwargs...) =
    POE_chat_completion(c,
        [Dict("role" => "user", "content" => user_content)];
        kwargs...
    )
POE_chat_completion(c::POEClient, messages::Vector{Dict{String, String}}, user_content::String; kwargs...) =
    POE_chat_completion(c,
        vcat(messages, Dict("role" => "user", "content" => user_content));
        kwargs...
    )
function POE_chat_completion(c::POEClient, messages::Vector{Dict{String, String}};
    return_json=false
)
    url = __build_URL(c, "chat/completions")
    headers = __build_headers!(POEClient, c)
    body_dict = Dict(
        "model" => __model(c),
        "messages" => messages,
    )
    body = JSON.json(body_dict)
    response = HTTP.post(url; headers=headers, body=body, connect_timeout=__timeout(c))
    response_body = JSON.parse(String(response.body))
    return_json && return response_body

    all_choices = response_body["choices"]
    isempty(all_choices) && error("No choices returned from POE API.")

    messages_list = fill(messages, length(all_choices))
    for (ii, choice) ∈ enumerate(all_choices)
        new_message = choice["message"]
        messages_list[ii] = vcat(messages_list[ii], Dict(new_message))
    end

    return messages_list
end
