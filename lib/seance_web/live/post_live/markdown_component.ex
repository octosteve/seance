defmodule SeanceWeb.PostLive.MarkdownComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="markdown-component">
      <%= f = form_for @changeset, "#",
      class: "markdown-form",
      phx_target: @myself,
      phx_change: "update" %>
        <textarea
            phx_debounce="2000"
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

    backtick_pattern = ~r/^```\z/m

    if Regex.match?(backtick_pattern, content) do
      content = String.replace(content, backtick_pattern, "")

      send(self(), {:update, id, content})
      send(self(), :collect_code_file)
      {:noreply, socket}
    else
      send(self(), {:update, id, content})
      {:noreply, socket}
    end
  end

  def rows_for(content) do
    content |> String.split("\n") |> length()
  end
end
