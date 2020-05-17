defmodule Seance.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :tags, {:array, :string}, default: []
    field :body, {:array, :map}, default: []

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :tags, :body])
    |> validate_required([:title])
  end
end
