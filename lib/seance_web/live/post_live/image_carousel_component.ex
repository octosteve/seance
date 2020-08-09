defmodule SeanceWeb.PostLive.ImageCarouselComponent do
  use SeanceWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="image-carousel-component" >
    <%= link to: "#", phx_target: @myself, phx_click: "select", phx_value_image_id: get_image(@images, @current_image_index).id do %>
      <%= img_tag get_image(@images, @current_image_index).url %>
    <% end %>
    </div>
    """
  end

  def get_image([], _index), do: %Unsplash.Image{url: "", id: ""}

  def get_image(images, index) do
    Enum.at(images, index)
  end
end
