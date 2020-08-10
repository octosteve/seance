defmodule Seance.Blog.EditablePost do
  defstruct [:id, :title, :tags, :body]
  alias Seance.Blog.Post
  alias Seance.Blog.BodyTypes.Markdown
  alias Seance.Blog.BodyTypes.Code
  alias Seance.Blog.BodyTypes.Image

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
      case {Enum.at(list, index - 1), Enum.at(list, index + 1)} do
        {%Markdown{}, %Markdown{content: overflow_content}} ->
          list
          |> List.delete_at(index)
          |> List.delete_at(index)
          |> List.update_at(
            index - 1,
            fn item ->
              Map.update(item, :content, "", fn
                nil ->
                  overflow_content

                content ->
                  content <> " " <> to_string(overflow_content)
              end)
            end
          )
          |> convert_body_for_db()

        _ ->
          list
          |> List.delete_at(index)
          |> convert_body_for_db()
      end
    end)
  end

  def add_code_node(%__MODULE__{} = post, insert_after, gist) do
    update_in(post.body, fn list ->
      list
      |> List.insert_at(insert_after + 1, Code.new(gist))
      |> List.insert_at(insert_after + 2, Markdown.new())
    end)
  end

  def add_image_node(%__MODULE__{} = post, insert_after, image) do
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

  def convert_body_for_db([%Code{} = node | rest]) do
    [Code.to_node(node) | convert_body_for_db(rest)]
  end

  def convert_body_for_db([%Image{} = node | rest]) do
    [Image.to_node(node) | convert_body_for_db(rest)]
  end

  def struct_for("markdown"), do: Markdown
  def struct_for("code"), do: Code
  def struct_for("image"), do: Image
end
