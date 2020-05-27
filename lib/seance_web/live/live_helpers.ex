defmodule SeanceWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `SeanceWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, SeanceWeb.PostLive.FormComponent,
        id: @post.id || :new,
        action: @live_action,
        post: @post,
        on_return: {:redirect, Routes.post_index_path(@socket, :index)} %>
  """
  def live_modal(socket, component, opts) do
    on_return = Keyword.fetch!(opts, :on_return)
    modal_opts = [id: :modal, on_return: on_return, component: component, opts: opts]
    live_component(socket, SeanceWeb.ModalComponent, modal_opts)
  end
end
