defmodule Seance.Blog.BodyTypes.Markdown do
  @behaviour Seance.Blog.BodyTypeBehaviour
  defstruct [:id, :content]

  def new(content \\ "") do
    %__MODULE__{id: Ecto.UUID.generate(), content: content}
  end

  def from_node(%{"id" => id, "content" => content}) do
    struct!(__MODULE__, id: id, content: content)
  end

  def to_node(%{id: id, content: content}) do
    %{"type" => "markdown", "id" => id, "content" => content}
  end
end
