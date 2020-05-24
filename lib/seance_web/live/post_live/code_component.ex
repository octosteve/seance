defmodule SeanceWeb.PostLive.CodeComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <button type="button" class="close" aria-label="Close" phx-click="delete" phx-value-id="<%= @id %>">
        <span aria-hidden="true">&times;</span>
      </button>
      <span phx-update="ignore" phx-target="<%= @myself %>" id="editor-<%= @id %>">
        <pre data-language="<%= @language %>" data-id="<%= @id %>" phx-hook="LinkEditor"><%= @content %></pre>
      </span>
    </div>
    """
  end

  @impl true
  def handle_event("update", %{"node" => %{"content" => content}}, socket) do
    id = socket.assigns.id
    send(self(), {:update, id, content})
    {:noreply, socket}
  end
end
