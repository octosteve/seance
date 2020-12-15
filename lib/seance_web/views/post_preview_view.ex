defmodule SeanceWeb.PostPreviewView do
  use SeanceWeb, :view

  def render("markdown", %{post: post}) do
    header = """
    ---
    title: #{post.title}
    tags: #{inspect(post.tags)}
    ---
    """

    body =
      for node <- post.body do
        case node do
          %Seance.Blog.BodyTypes.Code{gist_id: gist_id} ->
            ~s{<script src="https://gist.github.com/StevenNunez/#{gist_id}.js"></script>}
            |> give_space

          %Seance.Blog.BodyTypes.Image{} = image ->
            Seance.Blog.BodyTypes.Image.to_html_attribution(image)
            |> give_space

          %Seance.Blog.BodyTypes.Markdown{content: nil} ->
            ""

          %Seance.Blog.BodyTypes.Markdown{content: content} ->
            content
            |> give_space

          %Seance.Blog.BodyTypes.MermaidChart{content: nil} ->
            ""

          %Seance.Blog.BodyTypes.MermaidChart{} = chart ->
            chart
            |> Seance.Blog.BodyTypes.MermaidChart.to_markdown()
            |> give_space
        end
      end

    [header] ++ body
  end

  defp give_space(content) when is_list(content) do
    ["\n"] ++ content ++ ["\n"]
  end

  defp give_space(content) when is_binary(content) do
    ["\n", content, "\n"]
  end
end
