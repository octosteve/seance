defmodule Seance.Blog.BodyTypes.Code do
  @behaviour Seance.Blog.BodyTypeBehaviour
  use Ecto.Schema
  embedded_schema do
    field :content, :string
    field :language, :string
    field :gist_id, :string
  end
#  defstruct [:id, :content, :language, :gist_id]

  def new(opts \\ [content: ~s{IO.puts("Hello there")}, language: "elixir"]) do
    content = opts[:content]
    language = opts[:language]
    %__MODULE__{content: content, language: language, id: Ecto.UUID.generate()}
  end

  def changeset do
    new() |> Ecto.Changeset.change(%{})
  end

  def from_node(%{"id" => id, "content" => content, "language" => language, "gist_id" => gist_id}) do
    struct!(__MODULE__, id: id, content: content, language: language, gist_id: gist_id)
  end

  def to_node(%{id: id, content: content, language: language, gist_id: gist_id}) do
    %{
      "type" => "code",
      "id" => id,
      "content" => content,
      "language" => language,
      "gist_id" => gist_id
    }
  end
end
