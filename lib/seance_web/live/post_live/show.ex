defmodule SeanceWeb.PostLive.Show do
  use SeanceWeb, :live_view

  alias Seance.Blog
  alias Seance.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post = Blog.get_post!(id)
    {:ok, rendered_body, _} = post.body
                              |> Earmark.as_html
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:post, post)
      |> assign(:post_preview, post_preview(post))
    }
  end


  def post_preview(post) do
    """
      <h1>#{post.title}</h1>
      <h3>Tagged as: #{post.tags}</h3>
      #{rendered_body(post)}
    """
  end
  def rendered_body(%Post{body: body}) do
    {:ok, rendered_body, _} = body
                              |> Earmark.as_html
    rendered_body
  end
  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
