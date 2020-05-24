defmodule SeanceWeb.PostLive.AddCodeComponent do
  use SeanceWeb, :live_component

  def handle_event("add_code", %{"code" => %{"filename" => filename}}, socket) do
    send self(), {:add_code_to_post, filename}
    {:noreply, socket}
  end
end
