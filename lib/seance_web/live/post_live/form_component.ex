defmodule SeanceWeb.PostLive.FormComponent do
  use SeanceWeb, :live_component

  alias Seance.Blog
  alias Seance.Blog.BodyTypes.Code

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Blog.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:adding_code, false)}
  end

  @impl true
  def handle_event("add_code", _params, socket) do
    {:noreply, socket |> assign(:adding_code, true) |> assign(:code, Code.changeset())}
  end

  @impl true
  def handle_event("add_markdown", _params, socket) do
    send(self(), {:add_markdown_to_post})
    {:noreply, socket}
  end

  @impl true
  def handle_event("code_updated", %{"id" => id, "content" => content}, socket) do
    send(self(), {:update, id, content})
    {:noreply, socket}
  end

  def render_node(socket, %Seance.Blog.BodyTypes.Markdown{} = node, assigns) do
    live_component(socket, SeanceWeb.PostLive.MarkdownComponent,
      id: node.id,
      content: node.content,
      changeset: assigns.changeset
    )
  end

  def render_node(socket, %Seance.Blog.BodyTypes.Code{} = node, assigns) do
    live_component(socket, SeanceWeb.PostLive.CodeComponent,
      id: node.id,
      content: node.content,
      language: node.language,
      gist_id: node.gist_id,
      filename: node.filename
    )
  end
end
