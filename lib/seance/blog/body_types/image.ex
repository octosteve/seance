defmodule Seance.Blog.BodyTypes.Image do
  @behaviour Seance.Blog.BodyTypeBehaviour
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, apply_action!: 2, change: 2]

  embedded_schema do
    field :url, :string
    field :creator_name, :string
    field :creator_username, :string
    field :source, :string
  end

  def new(content \\ "") do
    %__MODULE__{id: Ecto.UUID.generate()}
  end

  def changeset do
    new()
    |> change(%{})
  end

  def from_node(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :url, :creator, :source])
    |> apply_action!(:from_node)
  end

  def to_node(%__MODULE__{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.put(:type, "image")
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
  end
end
