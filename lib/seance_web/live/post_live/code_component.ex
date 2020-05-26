defmodule SeanceWeb.PostLive.CodeComponent do
  use SeanceWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:gist_server, fn ->
        {:ok, pid} = GSAfraidOfGithub.start_link(assigns.gist_id, assigns.filename)
        pid
      end)

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <button type="button" class="close" aria-label="Close" phx-target="<%= @myself %>" phx-click="delete">
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
    GSAfraidOfGithub.send_code(socket.assigns.gist_server, content)
    id = socket.assigns.id
    send(self(), {:update, id, content})
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    GSAfraidOfGithub.stop(socket.assigns.gist_server)
    Seance.Clients.Github.delete_gist(socket.assigns.gist_id)
    send(self(), {:delete, socket.assigns.id})
    {:noreply, socket}
  end
end

defmodule GSAfraidOfGithub do
  use GenServer
  alias Seance.Clients.Github

  def start_link(gist_id, filename) do
    GenServer.start_link(__MODULE__, {gist_id, filename})
  end

  def send_code(pid, content) do
    GenServer.cast(pid, {:update_content, content})
  end

  def stop(pid), do: GenServer.stop(pid)

  def init({gist_id, filename}) do
    :timer.send_interval(5 |> :timer.seconds(), :sync_with_github)
    {:ok, %{gist_id: gist_id, filename: filename, pending: false, content: ""}}
  end

  def handle_cast({:update_content, content}, state) do
    {:noreply, %{state | pending: true, content: content}}
  end

  def handle_info(:sync_with_github, %{pending: false} = state), do: {:noreply, state}

  def handle_info(
        :sync_with_github,
        %{gist_id: gist_id, filename: filename, content: content} = state
      ) do
    Github.update_gist(gist_id, filename, content)
    {:noreply, %{state | pending: false}}
  end
end
