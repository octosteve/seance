defmodule Imgur.Image do
  defstruct [:id, :url, :thumb_url, :creator_account_url, :raw]

  def from_result(
        %{
          id: id,
          images: [%{link: url} | _rest],
          account_url: account_url
        } = raw
      ) do
    struct!(__MODULE__,
      id: id,
      url: url,
      thumb_url: generate_thumb_url(url),
      creator_account_url: account_url,
      raw: raw
    )
  end

  def from_result(
        %{
          id: id,
          link: url,
          account_url: account_url
        } = raw
      ) do
    struct!(__MODULE__,
      id: id,
      url: url,
      thumb_url: generate_thumb_url(url),
      creator_account_url: account_url,
      raw: raw
    )
  end

  def generate_thumb_url(url) do
    String.replace(url, ~r/(\.\w+)$/, "m\\1")
  end
end

defmodule Imgur.Search do
  defstruct [:query, :images]

  def new(query) do
    struct!(__MODULE__, query: query)
  end

  def to_url(%__MODULE__{query: query}) do
    URI.encode("/gallery/search/?q=#{query}&q_type=png")
  end

  def add_results(%__MODULE__{} = struct, %{data: data}) do
    images =
      data
      |> Enum.map(&Imgur.Image.from_result/1)

    struct
    |> Map.put(:images, images)
  end
end

defmodule Seance.Clients.Imgur do
  @base_url "https://api.imgur.com/3/"

  def search(query) do
    search = Imgur.Search.new(query)

    {:ok, %{body: body}} =
      HTTPoison.get(
        "#{@base_url}/#{Imgur.Search.to_url(search)}",
        headers()
      )

    results = body |> Jason.decode!(keys: :atoms)

    search
    |> Imgur.Search.add_results(results)
  end

  def upload(image) do
    endpoint = "#{@base_url}/image"

    task =
      Task.async(fn ->
        {:ok, %{body: body}} =
          HTTPoison.post(endpoint, {:multipart, [{"image", image}]}, headers())

        body
        |> Jason.decode!(keys: :atoms)
        |> Map.get(:data)
        |> Imgur.Image.from_result()
      end)

    Task.await(task)
  end

  defp headers do
    client_id = System.get_env("IMGUR_CLIENT_ID")
    [Authorization: "Client-ID #{client_id}"]
  end
end
