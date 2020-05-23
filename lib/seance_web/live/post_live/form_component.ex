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
    socket =
      socket
      |> assign(:post, Blog.add_code_to_post(socket.assigns.post))

    {:noreply, socket}
  end

  @impl true
  def handle_event("code_updated", %{"id" => id, "content" => content}, socket) do
    IO.puts("received some code for id: #{id}, content: #{content}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_post", %{"post" => post_params}, socket) do
    IO.inspect(post_params, label: "POST PARAMS")
    {:ok, post} = Blog.update_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, :post, post)}
  end

  def render_node(%Seance.Blog.BodyTypes.Markdown{} = node, assigns) do
    ~L"""
      <textarea
          phx_debounce="2000"
          phx_value-id="<%= node.id %>"
          class= "form-control"
          name="post[body][<%= node.id %>]"
          id="<%= node.id %>">
          <%= node.content %>
      </textarea>
    """
  end

  def render_node(%Seance.Blog.BodyTypes.Code{} = node, assigns) do
    ~L"""
      <span phx-target="<%= @myself %>" phx-update="ignore" id="editor-<%= node.id %>">
        <pre data-language="<%= node.language %> data-id="<%= node.id %>" phx-hook="LinkEditor"><%= node.content %></pre>
      </span>
    """
  end
end
