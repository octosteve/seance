defmodule SeanceWeb.PostLive.MarkdownComponent.Content do
  defstruct [
    :body,
    :target_pid,
    :inserting_code_block,
    :unsplash_slash_command,
    :imgur_slash_command,
    :chart_slash_command,
    :buffer_update
  ]

  @code_block_pattern ~r/^```\z/m
  @unsplash_slash_command_pattern ~r{^/unsplash\z}m
  @imgur_slash_command_pattern ~r{^/imgur\z}m
  @chart_slash_command_pattern ~r{^/chart\z}m

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
      imgur_slash_command?(body) -> Map.put(struct, :imgur_slash_command, true)
      chart_slash_command?(body) -> Map.put(struct, :chart_slash_command, true)
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

  def resolve(%__MODULE__{imgur_slash_command: true, body: body} = struct) do
    body = String.replace(body, @imgur_slash_command_pattern, "")
    Map.put(struct, :body, body)
  end

  def resolve(%__MODULE__{chart_slash_command: true, body: body} = struct) do
    body = String.replace(body, @chart_slash_command_pattern, "")
    Map.put(struct, :body, body)
  end

  def resolve(%__MODULE__{buffer_update: true, body: body} = struct) do
    body = maybe_split_last_line(body)

    struct
    |> Map.put(:body, body)
  end

  defp maybe_split_last_line(body) do
    if last_line(body) |> String.length() < 60 do
      body
    else
      split_last_line(body)
    end
  end

  defp split_last_line(body) do
    split_last_word_pattern = ~r/\s(?=\S*$)/
    split_last_line_pattern = ~r/\n(?=.*$)/

    last_line =
      body
      |> last_line
      |> String.split(split_last_word_pattern)
      |> Enum.join("\n")

    if String.contains?(body, "\n") do
      [preserved_lines, _] =
        body
        |> String.split(split_last_line_pattern)

      Enum.join([preserved_lines, last_line], "\n")
    else
      last_line
    end
  end

  defp last_line(body) do
    body |> String.split("\n") |> List.last()
  end

  defp beginning_code_block?(content) do
    Regex.match?(@code_block_pattern, content)
  end

  defp unsplash_slash_command?(content) do
    Regex.match?(@unsplash_slash_command_pattern, content)
  end

  defp imgur_slash_command?(content) do
    Regex.match?(@imgur_slash_command_pattern, content)
  end

  defp chart_slash_command?(content) do
    Regex.match?(@chart_slash_command_pattern, content)
  end

  def row_count(%__MODULE__{body: nil}), do: 1

  def row_count(%__MODULE__{body: body}) do
    String.split(body, "\n") |> length
  end
end

defmodule SeanceWeb.PostLive.MarkdownComponent do
  alias SeanceWeb.PostLive.MarkdownComponent.Content
  use SeanceWeb, :live_component

  @impl true
  def update(assigns, socket) do
    assigns = Map.merge(socket.assigns, assigns)
    socket = Map.put(socket, :assigns, assigns)

    {:ok,
     socket
     |> assign(:content, Content.new(assigns.content))}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="markdown-component">
      <%= form_for @changeset, "#",
      class: "markdown-form",
      phx_target: @myself,
      phx_change: "update" %>
        <textarea
            class="w-full px-3 py-2 mt-5 text-gray-700 border rounded-lg focus:outline-none resize-none"
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

      %Content{imgur_slash_command: true, body: body} ->
        send(self(), {:update, id, body})
        send(self(), {:get_imgur_image_search, index})

      %Content{chart_slash_command: true, body: body} ->
        send(self(), {:update, id, body})
        send(self(), {:add_mermaid_chart, index})

      %Content{buffer_update: true, body: body} ->
        send(self(), {:update, id, body})
    end

    {:noreply, socket}
  end
end
