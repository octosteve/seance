defmodule Seance.Blog.BodyTypes.Image do
  @behaviour Seance.Blog.BodyTypeBehaviour
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, apply_action!: 2, change: 2]

  embedded_schema do
    field :external_id, :string
    field :url, :string
    field :thumb_url, :string
    field :creator_name, :string
    field :creator_username, :string
    field :source, :string
  end

  def new do
    %__MODULE__{}
  end

  def new(%Unsplash.Image{
        id: external_id,
        url: url,
        thumb_url: thumb_url,
        creator_name: creator_name,
        creator_username: creator_username
      }) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      external_id: external_id,
      url: url,
      thumb_url: thumb_url,
      creator_name: creator_name,
      creator_username: creator_username,
      source: "Unsplash"
    }
  end

  def new(%Imgur.Image{
        id: external_id,
        url: url,
        thumb_url: thumb_url,
        creator_account_url: creator_username
      }) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      external_id: external_id,
      url: url,
      thumb_url: thumb_url,
      creator_name: nil,
      creator_username: creator_username,
      source: "Imgur"
    }
  end

  def changeset do
    new()
    |> change(%{})
  end

  def from_node(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :id,
      :external_id,
      :url,
      :thumb_url,
      :creator_name,
      :creator_username,
      :source
    ])
    |> apply_action!(:from_node)
  end

  def to_node(%__MODULE__{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.put(:type, "image")
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
  end

  def to_html_attribution(%__MODULE__{source: "Unsplash"} = struct) do
    ~s{
<div>
  <img width="100%" src="#{struct.url}" />
<small>Photo by <a href="https://unsplash.com/@#{struct.creator_username}?utm_source=seance&utm_medium=referral">#{
      struct.creator_name
    }</a> on <a href="https://unsplash.com/?utm_source=seance&utm_medium=referral">Unsplash</a></small>
<div>
    }
  end

  def to_html_attribution(%__MODULE__{source: "Imgur"} = struct) do
    ~s{
<div>
<img width="100%" src="#{struct.url}" />
<div>}
  end
end
