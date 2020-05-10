defmodule SeanceWeb.PostLive.TitleComponent do
  use SeanceWeb, :live_component

  alias Seance.Blog
  alias Seance.Blog.Post

  @impl true
  def update(assigns, socket) do
    changeset = Blog.change_post(%Post{})

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end
end
