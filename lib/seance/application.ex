defmodule Seance.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Seance.Repo,
      # Start the Telemetry supervisor
      SeanceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Seance.PubSub},
      # Start the Endpoint (http/https)
      SeanceWeb.Endpoint
      # Start a worker by calling: Seance.Worker.start_link(arg)
      # {Seance.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SeanceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
