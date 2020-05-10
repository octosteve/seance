defmodule SeanceWeb.PostLive.New do
  use SeanceWeb, :live_view

  alias Seance.Blog
  alias Seance.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, fetch_posts())}
  end

  def render_stage_component(:new, socket) do
    live_component(socket, SeanceWeb.PostLive.TitleComponent)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Blog.get_post!(id)

    socket
    |> assign(:page_title, "Author Mode")
    |> assign(:post, post)
  end


  @impl true
  def handle_event("initialize_post", %{"post" => attrs}, socket) do
    {:ok, post} = Blog.create_post(attrs)
    {:noreply, push_patch(socket, to: Routes.post_new_path(socket, :edit, post.id))}
  end

  defp fetch_posts do
    Blog.list_posts()
  end
end
