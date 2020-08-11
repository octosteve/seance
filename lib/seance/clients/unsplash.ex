defmodule Unsplash.Image do
  defstruct [:id, :url, :thumb_url, :creator_name, :creator_username]

  def from_result(%{
        id: id,
        urls: %{small: url, thumb: thumb_url},
        user: %{name: creator_name, username: creator_username}
      }) do
    struct!(__MODULE__,
      id: id,
      url: url,
      thumb_url: thumb_url,
      creator_name: creator_name,
      creator_username: creator_username
    )
  end
end

defmodule Unsplash.Search do
  defstruct [:query, :current_page, :total_pages, :total_images, :images]

  def new(query) do
    struct!(__MODULE__, query: query, current_page: 1)
  end

  def to_url(%__MODULE__{query: query, current_page: current_page}) do
    URI.encode("search/photos?page=#{current_page}&query=#{query}")
  end

  def add_results(%__MODULE__{} = struct, %{
        total: total_images,
        total_pages: total_pages,
        results: results
      }) do
    images =
      results
      |> Enum.map(&Unsplash.Image.from_result/1)

    struct
    |> Map.put(:total_pages, total_pages)
    |> Map.put(:total_images, total_images)
    |> Map.put(:images, images)
  end
end

defmodule Seance.Clients.Unsplash do
  @base_url "https://api.unsplash.com/"
  def search(query) do
    search = Unsplash.Search.new(query)

    {:ok, %{body: body}} =
      HTTPoison.get("#{@base_url}/#{Unsplash.Search.to_url(search)}", headers())

    results = body |> Jason.decode!(keys: :atoms)

    search
    |> Unsplash.Search.add_results(results)
  end

  defp headers do
    client_id = System.get_env("UNSPLASH_ACCESS_KEY")
    [Authorization: "Client-ID #{client_id}"]
  end
end
