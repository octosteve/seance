defmodule Seance.Blog.EditablePost do
  defstruct [:id, :title, :tags, :body]
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.Markdown
  alias Seance.Blog.BodyTypes.Code

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

  def remove_post_node(%__MODULE__{} = post, id) do
    post.body
    |> Enum.reduce([], fn node, acc ->
      if node.id == id do
        acc
      else
        acc ++ [node]
      end
    end)
    |> convert_body_for_db
  end

  def add_code_node(%__MODULE__{} = post, gist) do
    update_in(post.body, &(&1 ++ [Code.new(gist)]))
  end

  def add_markdown_node(%__MODULE__{} = post) do
    update_in(post.body, &(&1 ++ [Markdown.new()]))
  end

  def from_db(%Post{id: id, title: title, tags: tags, body: []}) do
    %__MODULE__{id: id, title: title, tags: tags, body: [Markdown.new()]}
  end

  def from_db(%Post{id: id, title: title, tags: tags, body: body}) do
    %__MODULE__{id: id, title: title, tags: tags, body: convert_body_from_db(body)}
  end

  def for_db(%__MODULE__{id: id, title: title, tags: tags, body: body} = post) do
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

  def convert_body_for_db([%Code{} = node | rest]) do
    [Code.to_node(node) | convert_body_for_db(rest)]
  end

  def struct_for("markdown"), do: Markdown
  def struct_for("code"), do: Code
end
