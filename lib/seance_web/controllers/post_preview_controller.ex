defmodule SeanceWeb.PostPreviewController do
  use SeanceWeb, :controller
  alias Seance.Blog

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, "show.html", preview: generate_preview(post), post: post)
  end

  def generate_preview(post) do
    {:ok, html, _} = Earmark.as_html(post.body)
    html
  end
end
