defmodule MainWebsite.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    Cosmic.fetch_all()
    MainWebsite.EventCache.fetch_or_load()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint
      supervisor(MainWebsite.Endpoint, []),
      worker(Ak.List, []),
      worker(Ak.Signup, []),
      worker(Ak.Petition, [])
    ]

    opts = [strategy: :one_for_one, name: MainWebsite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MainWebsite.Endpoint.config_change(changed, removed)
    :ok
  end
end
