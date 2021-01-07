defmodule SeanceWeb.HomeLive do
  use SeanceWeb, :live_view
  alias Seance.Blog

  @impl true
  def mount(_params, _session, socket) do
    posts =
      Blog.list_posts()
      |> Enum.map(fn post ->
        body =
          for %{"content" => content, "type" => "markdown"} <- post.body, reduce: "" do
            acc -> acc <> to_string(content)
          end

        %{post | body: body}
      end)

    {:ok, assign(socket, posts: posts)}
  end
end
