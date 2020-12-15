defmodule SeanceWeb.PostLive.MermaidChartComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="mermaid-chart-component">
      <button type="button" class="close" aria-label="Close" phx-target="<%= @myself %>" phx-click="delete">
        <span aria-hidden="true">&times;</span>
      </button>
      <%= f = form_for @changeset, "#",
      class: "mermaid-chart-form",
      phx_target: @myself,
      phx_change: "update" %>
        <textarea
            class="form-control"
            phx-debounce="1000"
            name="node[graph]"
            phx-hook="AutoFocus"
            id="<%= @id %>"><%= @content %></textarea>
      </form>
      <span phx-update="ignore" phx-target="<%= @myself %>">
        <div
          phx-hook="HandleChart"
          data-id="<%= @id %>">
          <span id="preview-<%= @id %>"></span>
        </div>
      </span>
    </div>
    """
  end

  @impl true
  def handle_event("update", %{"node" => %{"graph" => graph}}, socket) do
    index = socket.assigns.index
    id = socket.assigns.id

    send(self(), {:update, id, graph})
    {:noreply, push_event(socket, "update_chart", %{id: id, graph: graph})}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    send(self(), {:delete, socket.assigns.index})
    {:noreply, socket}
  end
end
