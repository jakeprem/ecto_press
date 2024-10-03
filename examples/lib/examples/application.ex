defmodule Examples.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Examples.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Examples.Supervisor)
  end
end
