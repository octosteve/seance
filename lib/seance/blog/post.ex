defmodule Seance.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :binary
    field :tags, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :tags, :body])
    |> validate_required([:title, :tags, :body])
  end
end