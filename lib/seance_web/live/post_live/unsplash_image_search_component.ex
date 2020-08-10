defmodule SeanceWeb.PostLive.UnsplashImageSearchComponent do
  use SeanceWeb, :live_component
  alias Seance.Clients.Unsplash

  def handle_event("search", %{"image" => %{"q" => query}}, socket) do
    search = Unsplash.search(query)
    send(self(), {:update_unsplash_images, search.images})
    {:noreply, assign(socket, :search, search)}
  end

  def handle_event("select", %{"image-id" => image_id}, socket) do
    images = socket.assigns.images
    selected_image = Enum.find(images, &(&1.id == image_id))
    send(self(), {:add_image, selected_image})

    {:noreply, socket}
  end

  def handle_event("previous", _params, socket) do
    send(self(), :decrement_image_index)
    {:noreply, socket}
  end

  def handle_event("next", _params, socket) do
    send(self(), :increment_image_index)
    {:noreply, socket}
  end
end
