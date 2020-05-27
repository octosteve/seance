defmodule Github.Gist do
  defstruct [:id, :language, :filename]
end

defmodule Seance.Clients.Github do
  def create_gist(filename) do
    request_body =
      %{files: %{filename => %{content: "tk"}}}
      |> Jason.encode!()

    {:ok, %{body: body}} =
      HTTPoison.post(
        "https://api.github.com/gists",
        request_body,
        headers()
      )

    %{"id" => id} = parsed = body |> Jason.decode!()
    language = get_in(parsed, ["files", filename, "language"])

    {:ok, %Github.Gist{id: id, language: language, filename: filename}}
  end

  def update_gist(gist_id, filename, content) do
    request_body =
      %{files: %{filename => %{content: content}}}
      |> Jason.encode!()

    {:ok, %{status_code: 200}} =
      HTTPoison.patch("https://api.github.com/gists/#{gist_id}", request_body, headers())
  end

  def delete_gist(gist_id) do
    {:ok, %{status_code: 204}} =
      HTTPoison.delete("https://api.github.com/gists/#{gist_id}", headers())
  end

  defp headers do
    token = System.get_env("GITHUB_AUTH_TOKEN")
    [Authorization: "token #{token}"]
  end
end
