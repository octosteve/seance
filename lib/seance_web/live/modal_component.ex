defmodule SeanceWeb.ModalComponent do
  use SeanceWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal" phx-capture-click="close" phx-window-keydown="close" phx-key="escape" phx-target="#<%= @id %>" phx-page-loading>
      <div class="modal" tabindex="-1" role="dialog" style="display: block">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Edit Post</h5>
                <%= live_patch to: @return_to, class: "button phx-modal-close" do %>
                  <span aria-hidden="true">&times;</span>
                <% end %>
            </div>
      <div class="modal-body">
        <%= live_component @socket, @component, @opts %>
      </div>
      <div class="modal-footer">
      </div>
    </div>
    </div>
    </div>

      <h1> here</h1>
      <div class="phx-modal-content">
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
