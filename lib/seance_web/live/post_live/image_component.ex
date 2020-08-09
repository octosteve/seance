defmodule SeanceWeb.PostLive.ImageComponent do
  use SeanceWeb, :live_component
  @code_block_pattern ~r/^```\z/m
  @unsplash_slash_command_pattern ~r{^/unsplash\z}m

  def render(assigns) do
    ~L"""
    <div class="image-component">
      <button type="button" class="close" aria-label="Close" phx-target="<%= @myself %>" phx-click="delete">
        <span aria-hidden="true">&times;</span>
      </button>
    <%= link @creator_name, to: @url %>
    </div>
    """
  end

  @impl true
  def handle_event("delete", _params, socket) do
    send(self(), {:delete, socket.assigns.index})
    {:noreply, socket}
  end
end
