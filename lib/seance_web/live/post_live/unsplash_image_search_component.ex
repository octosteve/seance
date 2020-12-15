defmodule SeanceWeb.PostLive.UnsplashImageSearchComponent do
  use SeanceWeb, :live_component
  alias Seance.Clients.Unsplash

  def handle_event("search", %{"image" => %{"q" => query}}, socket) do
    search = Unsplash.search(query)
    send(self(), {:update_images, search.images})
    {:noreply, assign(socket, :search, search)}
  end
end
