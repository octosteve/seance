defmodule SeanceWeb.PostLive.AddCodeComponent do
  use SeanceWeb, :live_component
  alias Seance.Clients.Github

  def handle_event("add_code", %{"code" => %{"filename" => filename}}, socket) do
    {:ok, gist} = Github.create_gist(filename)
    send(self(), {:add_code_to_post, gist})
    {:noreply, socket}
  end
end
