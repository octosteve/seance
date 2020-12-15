defmodule SeanceWeb.PostLive.ImageCarouselComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div>
    <%= if @current_image_index > 0 do %>
      <%= link "Previous", to: "#", phx_target: @myself, phx_click: "previous" %>
    <% end %>
    <%= if @current_image_index < length(@images) do %>
      <%= link "Next", to: "#", phx_target: @myself, phx_click: "next" %>
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
    Enum.at(images, index)
  end
end
