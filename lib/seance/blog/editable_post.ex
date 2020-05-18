defmodule Seance.Blog.EditablePost do
  defstruct [:title, :tags, :body]
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.Markdown
  alias Seance.Blog.BodyTypes.Code

  def from_db(%Post{title: title, tags: tags, body: body}) do
    %__MODULE__{title: title, tags: tags, body: convert_body_from_db(body)}
  end

  def for_db(%__MODULE__{title: title, tags: tags, body: body} = post) do
    %Post{title: title, tags: tags, body: convert_body_for_db(body)}
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
