# EctoPress

[EctoPress](https://hex.pm/packages/ecto_press)([Docs](https://hexdocs.pm/ecto_press)) is a library that will generate your context functions at compile time with a minimal amount of configuration, and just enough customizability.

Very much inspired by [EctoResource](https://github.com/testdouble/ecto_resource).

The main difference is that EctoPress defines a `ResourceProvider` behaviour that you can implement and set to customize how each callback functions.

This is still an early draft so there's likely to be rough edges, especially in the documentation.
The DSL and/or behaviour may change as certain things become clearer but the goal is to change it as infrequently as possible, iterating towards a very stable behaviour definition.

Most likely will work with earlier versions of Elixir but I've only tested down to 1.15.
If you need it to work with an earlier version, feel free to fork and test locally. I'd be happy to push the version down to be as compatible as possible.

See `examples/` for a more complete demonstration.

```elixir
defmodule MyApp.CustomResourceProvider do
  use EctoPress.BaseResourceProvider

  def list(repo, schema, clauses, opts) do
    # Assuming you use a pattern where all your schemas have a `base_query` function.
    query =
      schema.base_query()

    super(repo, query, clauses, opts)
  end
end

defmodule MyApp.MyContext do
  # If no provider is specified, will use `EctoPress.BaseResourceProvider`
  use EctoPress, repo: MyApp.Repo, resource_provider: MyApp.CustomResourceProvider

  resource User, MyApp.User
  # Resources can also be customized individually. (CustomResourceProvider is redundant in this case.)
  resource Post, MyApp.Post, plural: "articles", only: [:list, :get], resource_provider: MyApp.CustomResourceProvider
end

----------------------------------------

alias MyApp.MyContext

iex> MyContext.list_users()
[%MyApp.User{}, ...]

# `use EctoPress.ResourceProvider` provides default functions for all callbacks.
iex> MyContext.get_user(1)
%MyApp.User{}

iex> MyContext.list_articles()
[%MyApp.Post{}, ...]
```

## Installation

The package can be installed
by adding `ecto_press` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_press, "~> 0.1.0"}
  ]
end
```