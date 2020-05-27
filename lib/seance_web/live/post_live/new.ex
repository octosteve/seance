defmodule SeanceWeb.PostLive.New do
  use SeanceWeb, :live_view

  alias Seance.Blog
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.Code

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:adding_code, false)
     |> assign(:insert_after, 0)}
  end

  def render_stage(:new, assigns, socket) do
    live_modal(
      socket,
      SeanceWeb.PostLive.TitleComponent,
      id: :new,
      title: page_title(:new),
      action: :new,
      post: assigns.post,
      on_return: {:redirect, Routes.home_path(socket, :index)}
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

  def page_title(:new), do: "New Post"
  def page_title(:edit), do: "Author Mode"

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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, post} = Blog.remove_post_node(socket.assigns.post, id)
    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_info({:update, id, content}, socket) do
    {:ok, post} = Blog.update_post_node(socket.assigns.post, id, content)

    {:noreply, assign(socket, :post, post)}
  end

  def handle_info({:delete, index}, socket) do
    {:ok, post} = Blog.remove_post_node(socket.assigns.post, index)
    {:noreply, assign(socket, :post, post)}
  end

  def handle_info({:add_code_to_post, gist}, socket) do
    insert_after = socket.assigns.insert_after
    IO.inspect(insert_after, label: "GOING TO INSERT AFTER THIS THING")
    {:ok, post} = Blog.add_code_to_post(socket.assigns.post, insert_after, gist)

    socket =
      socket
      |> assign(:post, post)
      |> assign(:insert_after, nil)

    {:noreply, socket |> assign(:post, post) |> assign(:adding_code, false)}
  end

  def handle_info({:collect_code_file, index}, socket) do
    {:noreply,
     socket
     |> assign(:adding_code, true)
     |> assign(:insert_after, index)
     |> assign(:code, Code.changeset())}
  end

  def handle_info(:cancel_code_colletion, socket) do
    {:noreply,
     socket
     |> assign(:adding_code, false)
     |> assign(:code, nil)}
  end
end
