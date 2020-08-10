defmodule SeanceWeb.PostLive.MarkdownComponent.Content do
  defstruct [:body, :target_pid, :inserting_code_block, :unsplash_slash_command, :buffer_update]
  @code_block_pattern ~r/^```\z/m
  @unsplash_slash_command_pattern ~r{^/unsplash\z}m

  def new(body) do
    struct!(__MODULE__, body: body)
  end

  def update(content) do
    content
    |> new
    |> prepare
    |> resolve
  end

  def prepare(%__MODULE__{body: body} = struct) do
    cond do
      beginning_code_block?(body) -> Map.put(struct, :inserting_code_block, true)
      unsplash_slash_command?(body) -> Map.put(struct, :unsplash_slash_command, true)
      true -> Map.put(struct, :buffer_update, true)
    end
  end

  def resolve(%__MODULE__{inserting_code_block: true, body: body} = struct) do
    body = String.replace(body, @code_block_pattern, "")
    Map.put(struct, :body, body)
  end

  def resolve(%__MODULE__{unsplash_slash_command: true, body: body} = struct) do
    body = String.replace(body, @unsplash_slash_command_pattern, "")
    Map.put(struct, :body, body)
  end

  def resolve(%__MODULE__{buffer_update: true} = struct) do
    struct
  end

  defp beginning_code_block?(content) do
    Regex.match?(@code_block_pattern, content)
  end

  defp unsplash_slash_command?(content) do
    Regex.match?(@unsplash_slash_command_pattern, content)
  end

  defp get_code_filename(socket, content) do
    content = String.replace(content, @code_block_pattern, "")
  end

  def row_count(%__MODULE__{body: nil}), do: 1

  def row_count(%__MODULE__{body: body}) do
    recommended_line_length = 80

    [
      (String.length(body) / recommended_line_length) |> ceil,
      String.split(body) |> length
    ]
    |> Enum.max()
  end
end

defmodule SeanceWeb.PostLive.MarkdownComponent do
  alias SeanceWeb.PostLive.MarkdownComponent.Content
  use SeanceWeb, :live_component

  def update(assigns, socket) do
    assigns = Map.merge(socket.assigns, assigns)
    socket = Map.put(socket, :assigns, assigns)

    {:ok,
     socket
     |> assign(:content, Content.new(assigns.content))}
  end

  def render(assigns) do
    ~L"""
    <div class="markdown-component">
      <%= f = form_for @changeset, "#",
      class: "markdown-form",
      phx_target: @myself,
      phx_change: "update" %>
        <textarea
            class= "form-control"
            rows="<%= Content.row_count(@content) %>"
            name="node[content]"
            id="<%= @id %>"><%= @content.body %></textarea>
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("update", %{"node" => %{"content" => content}}, socket) do
    content = Content.update(content)
    index = socket.assigns.index
    id = socket.assigns.id

    case content do
      %Content{inserting_code_block: true, body: body} ->
        send(self(), {:update, id, body})
        send(self(), {:get_code_filename, index})

      %Content{unsplash_slash_command: true, body: body} ->
        send(self(), {:update, id, body})
        send(self(), {:get_unsplash_image_search, index})

      %Content{buffer_update: true, body: body} ->
        send(self(), {:update, socket.assigns.id, body})
    end

    {:noreply, socket}
  end
end
