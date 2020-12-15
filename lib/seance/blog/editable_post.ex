defmodule Seance.Blog.EditablePost do
  defstruct [:id, :title, :tags, :body]
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.Markdown
  alias Seance.Blog.BodyTypes.Code
  alias Seance.Blog.BodyTypes.Image
  alias Seance.Blog.BodyTypes.MermaidChart

  def update_post_node(%__MODULE__{} = post, id, content) do
    post.body
    |> Enum.map(fn node ->
      if node.id == id do
        %{node | content: content}
      else
        node
      end
    end)
    |> convert_body_for_db
  end

  def remove_post_node(%__MODULE__{} = post, index) do
    update_in(post.body, fn list ->
      [former, latter] = [Enum.at(list, index - 1), Enum.at(list, index + 1)]

      case {former, latter} do
        {%Markdown{}, %Markdown{content: content}} ->
          list
          |> List.delete_at(index)
          |> List.delete_at(index)
          |> List.update_at(
            index - 1,
            fn item ->
              Map.update(item, :content, "", &merge_content(&1, content))
            end
          )

        _ ->
          list
          |> List.delete_at(index)
      end
    end)
  end

  defp merge_content(content1, nil), do: content1
  defp merge_content(nil, content2), do: content2
  defp merge_content(content1, content2), do: "#{content1}\n#{content2}"

  def add_mermaid_chart_node(%__MODULE__{} = post, insert_after) when is_integer(insert_after) do
    update_in(post.body, fn list ->
      list
      |> List.insert_at(insert_after + 1, MermaidChart.new())
      |> List.insert_at(insert_after + 2, Markdown.new())
    end)
  end

  def add_code_node(%__MODULE__{} = post, insert_after, gist) when is_integer(insert_after) do
    update_in(post.body, fn list ->
      list
      |> List.insert_at(insert_after + 1, Code.new(gist))
      |> List.insert_at(insert_after + 2, Markdown.new())
    end)
  end

  def add_image_node(%__MODULE__{} = post, insert_after, image) when is_integer(insert_after) do
    update_in(post.body, fn list ->
      list
      |> List.insert_at(insert_after + 1, Image.new(image))
      |> List.insert_at(insert_after + 2, Markdown.new())
    end)
  end

  def from_db(%Post{id: id, title: title, tags: tags, body: []}) do
    %__MODULE__{id: id, title: title, tags: tags, body: [Markdown.new()]}
  end

  def from_db(%Post{id: id, title: title, tags: tags, body: body}) do
    %__MODULE__{id: id, title: title, tags: tags, body: convert_body_from_db(body)}
  end

  def for_db(%__MODULE__{id: id, title: title, tags: tags, body: body}) do
    %Post{id: id, title: title, tags: tags, body: convert_body_for_db(body)}
  end

  def convert_body_from_db([]), do: []

  def convert_body_from_db([%{"type" => type} = node | rest]) do
    [struct_for(type).from_node(node) | convert_body_from_db(rest)]
  end

  def convert_body_for_db([]), do: []

  def convert_body_for_db([%Markdown{} = node | rest]) do
    [Markdown.to_node(node) | convert_body_for_db(rest)]
  end

  def convert_body_for_db([%MermaidChart{} = node | rest]) do
    [MermaidChart.to_node(node) | convert_body_for_db(rest)]
  end

  def convert_body_for_db([%Code{} = node | rest]) do
    [Code.to_node(node) | convert_body_for_db(rest)]
  end

  def convert_body_for_db([%Image{} = node | rest]) do
    [Image.to_node(node) | convert_body_for_db(rest)]
  end

  def struct_for("markdown"), do: Markdown
  def struct_for("mermaid_chart"), do: MermaidChart
  def struct_for("code"), do: Code
  def struct_for("image"), do: Image
end
