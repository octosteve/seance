defmodule SeanceWeb.PostLive.ImageComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="image-component">
      <button type="button" class="close" aria-label="Close" phx-target="<%= @myself %>" phx-click="delete">
        <span aria-hidden="true">&times;</span>
      </button>
    <%= img_tag @thumb_url %>
    </div>
    """
  end

  @impl true
  def handle_event("delete", _params, socket) do
    send(self(), {:delete, socket.assigns.index})
    {:noreply, socket}
  end
end
