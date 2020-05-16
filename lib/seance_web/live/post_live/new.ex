defmodule SeanceWeb.PostLive.New do
  use SeanceWeb, :live_view

  alias Seance.Blog
  alias Seance.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:code_examples, [])}
  end

  def render_stage(:new, assigns, socket) do
    live_modal(
      socket,
      SeanceWeb.PostLive.TitleComponent,
      id: :new,
      title: page_title(:new),
      action: :new,
      post: assigns.post,
      return_to: Routes.home_path(socket, :index)
    )
  end

  def render_stage(:edit, assigns, socket) do
    post = assigns.post

    live_component(socket, SeanceWeb.PostLive.FormComponent,
      id: post.id,
      title: post.title,
      post: post
    )
  end

  def render_stage(:preview, assigns, socket) do
    post = assigns.post
    live_component(socket, SeanceWeb.PostLive.PreviewComponent, id: post.id, post: post)
  end

  def page_title(:new), do: "New Post"
  def page_title(:edit), do: "Author Mode"
  def page_title(:preview), do: "Preview Mode"

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

  defp apply_action(socket, :preview, %{"id" => id}) do
    post = Blog.get_post!(id)

    socket
    |> assign(:page_title, "Preview Mode")
    |> assign(:post, post)
  end

  @impl true
  def handle_event("initialize_post", %{"post" => attrs}, socket) do
    {:ok, post} = Blog.create_post(attrs)
    {:noreply, push_patch(socket, to: Routes.post_new_path(socket, :edit, post.id))}
  end

  @impl true
  def handle_event("add_code", _params, socket) do
  {:noreply, update(socket, :code_examples, &([%{id: "123", content: "IO.puts(:yo_mama)"} | &1]))}
  end
end