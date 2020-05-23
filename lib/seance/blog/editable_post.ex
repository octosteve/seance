defmodule Seance.Blog.EditablePost do
  defstruct [:id, :title, :tags, :body]
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.Markdown
  alias Seance.Blog.BodyTypes.Code

  def update_attrs(%__MODULE__{} = post, attrs) do
    Map.new(attrs, fn
      {"body", m} ->
        body =
          Enum.map(post.body, fn node ->
            if m[node.id] do
              %{node | content: m[node.id]}
            else
              node
            end
          end)

        {"body", convert_body_for_db(body)}

      rest ->
        rest
    end)
  end

  def add_code_node(%__MODULE__{} = post) do
    update_in(post.body, &(&1 ++ [Code.new()]))
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
