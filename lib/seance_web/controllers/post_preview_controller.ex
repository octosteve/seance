defmodule SeanceWeb.PostPreviewController do
  use SeanceWeb, :controller
  alias Seance.Blog

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, "show.html", preview: generate_preview(post), post: post)
  end

  def generate_preview(post) do
    for node <- post.body do
      case node do
        %Seance.Blog.BodyTypes.Code{gist_id: gist_id} ->
          ~s{<script src="https://gist.github.com/StevenNunez/#{gist_id}.js"></script>}

        %Seance.Blog.BodyTypes.Markdown{content: content} ->
          {:ok, html, _} = Earmark.as_html(content)
          html
      end
    end
  end
end
