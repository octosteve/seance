defmodule Seance.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Seance.Blog.PostBodyNodeType

  schema "posts" do
    field :title, :string
    field :tags, :array
    field :body, {:array, PostBodyNodeType}

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :tags, :body])
    |> validate_required([:title])
  end
end
