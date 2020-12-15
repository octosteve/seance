defmodule SeanceWeb.Router do
  use SeanceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SeanceWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SeanceWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/posts/new", PostLive.New, :new
    live "/posts/:id/edit", PostLive.New, :edit

    get "/posts/:id/preview", PostPreviewController, :show

    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/show/edit", PostLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", SeanceWeb do
  #   pipe_through :api
  # end
end
