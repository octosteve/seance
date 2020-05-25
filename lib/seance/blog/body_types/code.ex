defmodule Seance.Blog.BodyTypes.Code do
  @behaviour Seance.Blog.BodyTypeBehaviour
  use Ecto.Schema

  alias Github.Gist

  embedded_schema do
    field :content, :string
    field :language, :string
    field :gist_id, :string
    field :filename, :string
  end

  def new(%Gist{id: gist_id, language: language, filename: filename}) do
    %__MODULE__{
      content: "",
      language: language,
      filename: filename,
      gist_id: gist_id,
      id: Ecto.UUID.generate()
    }
  end

  def new(opts \\ [content: ~s{IO.puts("Hello there")}, language: "elixir"]) do
    content = opts[:content]
    language = opts[:language]
    %__MODULE__{content: content, language: language, id: Ecto.UUID.generate()}
  end

  def changeset do
    new() |> Ecto.Changeset.change(%{})
  end

  def from_node(%{
        "id" => id,
        "content" => content,
        "language" => language,
        "gist_id" => gist_id,
        "filename" => filename
      }) do
    struct!(__MODULE__,
      id: id,
      content: content,
      language: language,
      gist_id: gist_id,
      filename: filename
    )
  end

  def to_node(%{
        id: id,
        content: content,
        language: language,
        gist_id: gist_id,
        filename: filename
      }) do
    %{
      "type" => "code",
      "id" => id,
      "content" => content,
      "language" => language,
      "gist_id" => gist_id,
      "filename" => filename
    }
  end
end
