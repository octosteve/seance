defmodule SeanceWeb.HomeLive do
  use SeanceWeb, :live_view
  alias Seance.Blog

  @impl true
  def mount(_params, _session, socket) do
    posts = Blog.list_posts()
    {:ok, assign(socket, posts: posts)}
  end
end
