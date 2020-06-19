defmodule Seance.Blog.BodyTypes.Code do
  @behaviour Seance.Blog.BodyTypeBehaviour
  use Ecto.Schema

  alias Github.Gist
  import Ecto.Changeset, only: [cast: 3, change: 2, apply_action!: 2]

  embedded_schema do
    field :content, :string
    field :language, :string
    field :gist_id, :string
    field :filename, :string
  end

  def new(opts \\ [content: ~s{IO.puts("Hello there")}, language: "elixir"])

  def new(%Gist{id: gist_id, language: language, filename: filename}) do
    %__MODULE__{
      content: "",
      language: language,
      filename: filename,
      gist_id: gist_id,
      id: Ecto.UUID.generate()
    }
  end

  def new(opts) do
    content = opts[:content]
    language = opts[:language]
    %__MODULE__{content: content, language: language, id: Ecto.UUID.generate()}
  end

  def changeset do
    new()
    |> change(%{})
  end

  def from_node(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :content, :language, :gist_id, :filename])
    |> apply_action!(:from_node)
  end

  def to_node(%__MODULE__{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.put(:type, "code")
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
  end
end
