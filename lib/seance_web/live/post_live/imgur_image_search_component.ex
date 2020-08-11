defmodule SeanceWeb.PostLive.ImgurImageSearchComponent do
  use SeanceWeb, :live_component
  alias Seance.Clients.Imgur

  def handle_event("search", %{"image" => %{"q" => query}}, socket) do
    search = Imgur.search(query)
    send(self(), {:update_images, search.images})
    {:noreply, assign(socket, :search, search)}
  end

  def handle_event("select", %{"image-id" => image_id}, socket) do
    images = socket.assigns.images
    selected_image = Enum.find(images, &(&1.id == image_id))
    send(self(), {:add_image, selected_image})

    {:noreply, socket}
  end

  def handle_event("upload", %{"image" => image}, socket) do
    image = Imgur.upload(image)
    send(self(), {:add_image, image})
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
