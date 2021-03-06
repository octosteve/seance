defmodule SeanceWeb.PostLive.New do
  use SeanceWeb, :live_view

  alias Seance.Blog
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.{Code, Image}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:adding_code, false)
     |> assign(:adding_unsplash_image, false)
     |> assign(:adding_imgur_image, false)
     |> assign(:images, [])
     |> assign(:current_image_index, 0)
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
    {:ok, post} = Blog.add_code_to_post(socket.assigns.post, insert_after, gist)

    socket =
      socket
      |> assign(:post, post)
      |> assign(:insert_after, nil)
      |> assign(:adding_code, false)

    {:noreply, socket}
  end

  def handle_info({:get_code_filename, index}, socket) do
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

  def handle_info({:add_image, image}, socket) do
    insert_after = socket.assigns.insert_after
    {:ok, post} = Blog.add_image_to_post(socket.assigns.post, insert_after, image)

    socket =
      socket
      |> assign(:post, post)
      |> assign(:images, [])
      |> assign(:insert_after, nil)
      |> assign(:adding_unsplash_image, false)
      |> assign(:adding_imgur_image, false)

    {:noreply, socket}
  end

  def handle_info({:add_mermaid_chart, insert_after}, socket) do
    {:ok, post} = Blog.add_mermaid_chart_to_post(socket.assigns.post, insert_after)

    socket =
      socket
      |> assign(:post, post)

    {:noreply, socket}
  end

  def handle_info({:update_images, images}, socket) do
    {:noreply,
     socket
     |> assign(:images, images)
     |> assign(:current_image_index, 0)}
  end

  def handle_info({:update_current_image, index}, socket) do
    {:noreply,
     socket
     |> assign(:current_image_index, index)}
  end

  def handle_info(:decrement_image_index, socket) do
    {:noreply,
     socket
     |> update(:current_image_index, &(&1 - 1))}
  end

  def handle_info(:increment_image_index, socket) do
    {:noreply,
     socket
     |> update(:current_image_index, &(&1 + 1))}
  end

  def handle_info(:reset_image_index, socket) do
    {:noreply,
     socket
     |> assign(:current_image_index, 0)}
  end

  def handle_info({:get_unsplash_image_search, index}, socket) do
    {:noreply,
     socket
     |> assign(:adding_unsplash_image, true)
     |> assign(:insert_after, index)
     |> assign(:image, Image.changeset())}
  end

  def handle_info(:cancel_unsplash_image_search, socket) do
    {:noreply,
     socket
     |> assign(:adding_unsplash_image, false)
     |> assign(:image, nil)
     |> assign(:images, [])
     |> assign(:current_image_index, 0)}
  end

  def handle_info({:get_imgur_image_search, index}, socket) do
    {:noreply,
     socket
     |> assign(:adding_imgur_image, true)
     |> assign(:insert_after, index)
     |> assign(:image, Image.changeset())}
  end

  def handle_info(:cancel_imgur_image_search, socket) do
    {:noreply,
     socket
     |> assign(:adding_imgur_image, false)
     |> assign(:image, nil)
     |> assign(:images, [])
     |> assign(:current_image_index, 0)}
  end
end
