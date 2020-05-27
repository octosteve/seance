defmodule SeanceWeb.ModalComponent do
  use SeanceWeb, :live_component

  @impl true
  def handle_event("close", _, socket) do
    case socket.assigns.on_return do
      {:redirect, path} ->
        {:noreply, push_patch(socket, to: path)}

      {:call, func} ->
        func.()
        {:noreply, socket}
    end
  end
end
