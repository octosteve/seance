defmodule Seance.Blog.BodyTypes.MermaidChart do
  @behaviour Seance.Blog.BodyTypeBehaviour
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, apply_action!: 2]

  embedded_schema do
    field :content, :string
  end

  def new(content \\ "") do
    %__MODULE__{id: Ecto.UUID.generate(), content: content}
  end

  def from_node(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :content])
    |> apply_action!(:from_node)
  end

  def to_node(%__MODULE__{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.put(:type, "mermaid_chart")
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
  end

  def to_markdown(%__MODULE__{content: content}) do
    escaped_content = String.replace(content, "--", "\\--")
    ~s{
<div class="mermaid">
#{escaped_content}
</div>}
  end
end
