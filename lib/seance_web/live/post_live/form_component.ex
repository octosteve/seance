defmodule SeanceWeb.PostLive.FormComponent do
  use SeanceWeb, :live_component

  alias Seance.Blog

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Blog.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:code_examples, [])}
  end

  @impl true
  def handle_event("add_code", _params, socket) do
  {:noreply, update(socket, :code_examples, &([%{id: Ecto.UUID.generate(), content: "IO.puts(#{:os.system_time(:millisecond)}})"} | &1]))}
  end

  @impl true
  def handle_event("update_post", %{"post" => post_params}, socket) do
    {:ok, post} = Blog.update_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, :post, post)}
  end
end
