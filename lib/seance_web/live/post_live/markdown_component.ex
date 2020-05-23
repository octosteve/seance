defmodule SeanceWeb.PostLive.MarkdownComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#",
    phx_target: @myself,
    phx_change: "update" %>
      <textarea
          phx_debounce="2000"
          phx_value-id="<%= @id %>"
          class= "form-control"
          name="node[content]"
          id="<%= @id %>"><%= @content %></textarea>
    </form>
    """
  end

  @impl true
  def handle_event("update", %{"node" => %{"content" => content}}, socket) do
    id = socket.assigns.id
    send(self(), {:update, id, content})
    {:noreply, socket}
  end
end
