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
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("code_updated", %{"id" => id, "content" => content}, socket) do
    send(self(), {:update, id, content})
    {:noreply, socket}
  end

  def render_node(socket, index, %Seance.Blog.BodyTypes.Markdown{} = node, assigns) do
    live_component(socket, SeanceWeb.PostLive.MarkdownComponent,
      id: node.id,
      content: node.content,
      changeset: assigns.changeset,
      index: index
    )
  end

  def render_node(socket, index, %Seance.Blog.BodyTypes.MermaidChart{} = node, assigns) do
    live_component(socket, SeanceWeb.PostLive.MermaidChartComponent,
      id: node.id,
      content: node.content,
      changeset: assigns.changeset,
      index: index
    )
  end

  def render_node(socket, index, %Seance.Blog.BodyTypes.Code{} = node, assigns) do
    live_component(socket, SeanceWeb.PostLive.CodeComponent,
      id: node.id,
      content: node.content,
      language: node.language,
      gist_id: node.gist_id,
      filename: node.filename,
      index: index
    )
  end

  def render_node(socket, index, %Seance.Blog.BodyTypes.Image{} = node, assigns) do
    live_component(socket, SeanceWeb.PostLive.ImageComponent,
      id: node.id,
      external_id: node.external_id,
      url: node.url,
      thumb_url: node.thumb_url,
      creator_name: node.creator_name,
      creator_username: node.creator_username,
      source: node.source,
      index: index
    )
  end
end
