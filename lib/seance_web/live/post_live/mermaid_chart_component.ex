defmodule SeanceWeb.PostLive.MermaidChartComponent do
  use SeanceWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="mermaid-chart-component">
      <button type="button" class="close" aria-label="Close" phx-target="<%= @myself %>" phx-click="delete">
        <span aria-hidden="true">&times;</span>
      </button>
      <%= form_for @changeset, "#",
      class: "mermaid-chart-form",
      phx_target: @myself,
      phx_change: "update" %>
        <textarea
            class="w-full px-3 py-2 mt-5 text-gray-700 border rounded-lg focus:outline-none resize-none"
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
