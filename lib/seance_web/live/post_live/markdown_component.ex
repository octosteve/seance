defmodule SeanceWeb.PostLive.MarkdownComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="markdown-component">
    <button type="button" class="close" aria-label="Close" phx-click="delete" phx-value-id="<%= @id %>">
      <span aria-hidden="true">&times;</span>
    </button>
    <%= f = form_for @changeset, "#",
    class: "markdown-form",
    phx_target: @myself,
    phx_change: "update" %>
      <textarea
          phx_debounce="2000"
          phx_value-id="<%= @id %>"
          class= "form-control"
          rows="<%= rows_for(@content) %>"
          name="node[content]"
          id="<%= @id %>"><%= @content %></textarea>
    </form>
    </div>
    """
  end

  @impl true
  def handle_event("update", %{"node" => %{"content" => content}}, socket) do
    id = socket.assigns.id
    send(self(), {:update, id, content})
    {:noreply, socket}
  end

  def rows_for(content) do
    content
    |> String.split("\n")
    |> Enum.reduce(0, fn line, total ->
      if String.length(line) > 80 do
        total + 1 + (div String.length(line), 80)
      else
        total + 1
      end
    end)
  end
end
