defmodule Seance.Blog.PostBodyNodeType do
  use Ecto.Type
  def ecto_callback(%{data: data, type: type}) do
    {:ok, result} = type
                    |> find_module
                    |> apply(:ecto_callback, [data])
    %{data: result, type: type}

  end

  defp find_module("code"), do: Seance.Blog.EctoTypes.Code
  defp find_module("markdown"), do: Seance.Blog.EctoTypes.Markdown
end

defmodule Seance.Blog.EctoTypes.Code do
  def ecto_callback(data) do

  end
end
defmodule Seance.Blog.EctoTypes.Markdown do
  def ecto_callback(data) do

  end
end
