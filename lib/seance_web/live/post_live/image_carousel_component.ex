defmodule SeanceWeb.PostLive.ImageCarouselComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="flex">
    <%= if @current_image_index > 0 do %>
      <%= link to: "#", phx_target: @myself, phx_click: "previous" do %>
        <svg class="h-10 text-gray-700" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 15l-3-3m0 0l3-3m-3 3h8M3 12a9 9 0 1118 0 9 9 0 01-18 0z" />
        </svg>
      <% end %>
    <% end %>
    <%= if @current_image_index < length(@images) do %>
      <%= link to: "#", phx_target: @myself, phx_click: "next" do %>
        <svg class="h-10 text-gray-700" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 9l3 3m0 0l-3 3m3-3H8m13 0a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      <% end %>
    <% end %>
    </div>
    <div class="image-carousel-component" >
    <%= link to: "#", phx_target: @myself, phx_click: "select", phx_value_image_id: get_image(@images, @current_image_index).id do %>
      <%= img_tag get_image(@images, @current_image_index).url %>
    <% end %>
    </div>
    """
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

  def get_image([], _index), do: %Unsplash.Image{url: "", id: ""}

  def get_image(images, index) do
    if image = Enum.at(images, index) do
      image
    else
      send(self(), :reset_image_index)
      Enum.at(images, 0)
    end
  end
end
