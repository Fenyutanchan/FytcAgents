# Copyright (c) 2025 Fenyutanchan <fenyutanchan@gmail.com>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

@test begin
    POE_client = POEClient(API_key=ENV["POE_API_KEY"])
    supported_models = get_model_list(POE_client)
    @info "All supported models in POE:\n    $(join(supported_models, "\n    "))"
    !isempty(supported_models)
end

@test begin
    POE_client = POEClient(
        model="Assistant",
        API_key=ENV["POE_API_KEY"]
    )
    messages_list = POE_chat_completion(POE_client, "Hello, what day is it today?")
    
    messages_list = vcat(
        POE_chat_completion.(Ref(POE_client), messages_list,
            Ref("Okay, what is the capital of China?")
        )...
    )

    for (ii, messages) ∈ enumerate(messages_list)
        @info """
        Conversation $(ii):
            $(join([message["role"] * ": " * message["content"] for message ∈ messages], "\n    "))
        """
    end
    !isempty(messages_list)
end
