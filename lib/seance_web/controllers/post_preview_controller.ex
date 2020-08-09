defmodule SeanceWeb.PostPreviewController do
  use SeanceWeb, :controller
  alias Seance.Blog

  def show(conn, %{"id" => id, "markdown" => "true"}) do
    post = Blog.get_post!(id)
    render(conn, "show_markdown.html", preview: generate_markdown_preview(post), post: post)
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, "show.html", preview: generate_preview(post), post: post)
  end

  def generate_preview(post) do
    for node <- post.body do
      case node do
        %Seance.Blog.BodyTypes.Code{gist_id: gist_id} ->
          ~s{<script src="https://gist.github.com/StevenNunez/#{gist_id}.js"></script>}

        %Seance.Blog.BodyTypes.Image{} = image ->
          Seance.Blog.BodyTypes.Image.to_html_attribution(image)

        %Seance.Blog.BodyTypes.Markdown{content: content} ->
          {:ok, html, _} = Earmark.as_html(content)
          html
      end
    end
  end

  def generate_markdown_preview(post) do
    for node <- post.body do
      case node do
        %Seance.Blog.BodyTypes.Code{gist_id: gist_id} ->
          {:code, ~s{<script src="https://gist.github.com/StevenNunez/#{gist_id}.js"></script>}}

        %Seance.Blog.BodyTypes.Image{} = image ->
          {:image, Seance.Blog.BodyTypes.Image.to_html_attribution(image)}

        %Seance.Blog.BodyTypes.Markdown{content: content} ->
          {:markdown, "<br />" <> String.replace(content, "\n", "<br />") <> "<br />"}
      end
    end
  end
end
