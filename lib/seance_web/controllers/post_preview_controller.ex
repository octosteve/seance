defmodule SeanceWeb.PostPreviewController do
  use SeanceWeb, :controller
  alias Seance.Blog

  def show(conn, %{"id" => id, "markdown" => "true"}) do
    post = Blog.get_post!(id)
    # render(conn, "show_markdown.html", preview: generate_markdown_preview(post), post: post)
    markdown =
      Phoenix.View.render_to_string(
        SeanceWeb.PostPreviewView,
        "markdown",
        post: post
      )

    text(conn, markdown)
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, "show.html", preview: generate_preview(post), post: post)
  end

  def generate_preview(post) do
    for node <- post.body do
      case node do
        %Seance.Blog.BodyTypes.Code{gist_id: gist_id} ->
          ~s{<script src="https://gist.github.com/octosteve/#{gist_id}.js"></script>}

        %Seance.Blog.BodyTypes.Image{} = image ->
          Seance.Blog.BodyTypes.Image.to_html_attribution(image)

        %Seance.Blog.BodyTypes.Markdown{content: nil} ->
          ""

        %Seance.Blog.BodyTypes.Markdown{content: content} ->
          {:ok, html, _} = Earmark.as_html(content)
          html

        %Seance.Blog.BodyTypes.MermaidChart{content: nil} ->
          ""

        %Seance.Blog.BodyTypes.MermaidChart{} ->
          "<h1>A chart goes here</h1>"
      end
    end
  end

  def generate_markdown_preview(post) do
    for node <- post.body do
      case node do
        %Seance.Blog.BodyTypes.Code{gist_id: gist_id} ->
          {:code, ~s{<script src="https://gist.github.com/octosteve/#{gist_id}.js"></script>}}

        %Seance.Blog.BodyTypes.Image{} = image ->
          {:image, Seance.Blog.BodyTypes.Image.to_html_attribution(image)}

        %Seance.Blog.BodyTypes.Markdown{content: nil} ->
          {:markdown, ""}

        %Seance.Blog.BodyTypes.Markdown{content: content} ->
          {:markdown, Phoenix.HTML.Format.text_to_html(content)}

        %Seance.Blog.BodyTypes.MermaidChart{content: nil} ->
          {:mermaid_chart, ""}

        %Seance.Blog.BodyTypes.MermaidChart{content: content} ->
          {:mermaid_chart, Phoenix.HTML.Format.text_to_html(content)}
      end
    end
  end
end
