defmodule Seance.Blog.BodyTypes.Code do
  @behaviour Seance.Blog.BodyTypeBehaviour
  defstruct [:id, :content, :language, :gist_id]

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
