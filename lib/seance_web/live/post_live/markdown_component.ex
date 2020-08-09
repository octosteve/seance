defmodule SeanceWeb.PostLive.MarkdownComponent do
  use SeanceWeb, :live_component
  @code_block_pattern ~r/^```\z/m
  @unsplash_slash_command_pattern ~r{^/unsplash\z}m

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
    cond do
      beginning_code_block?(content) -> get_code_filename(socket, content)
      unsplash_slash_command?(content) -> get_unsplash_image_search(socket, content)
      true -> update_buffer(socket, content)
    end

    {:noreply, socket}
  end

  defp beginning_code_block?(content) do
    Regex.match?(@code_block_pattern, content)
  end

  defp unsplash_slash_command?(content) do
    Regex.match?(@unsplash_slash_command_pattern, content)
  end

  defp update_buffer(socket, content) do
    send(self(), {:update, socket.assigns.id, content})
  end

  defp get_code_filename(socket, content) do
    index = socket.assigns.index
    id = socket.assigns.id
    content = String.replace(content, @code_block_pattern, "")

    send(self(), {:update, id, content})
    send(self(), {:get_code_filename, index})
  end

  defp get_unsplash_image_search(socket, content) do
    index = socket.assigns.index
    id = socket.assigns.id
    content = String.replace(content, @unsplash_slash_command_pattern, "")

    send(self(), {:update, id, content})
    send(self(), {:get_unsplash_image_search, index})
  end

  def rows_for(nil), do: 1

  def rows_for(content) do
    recommended_line_length = 80

    [
      (String.length(content) / recommended_line_length) |> ceil,
      String.split(content, "\n") |> length
    ]
    |> Enum.max()
  end
end
