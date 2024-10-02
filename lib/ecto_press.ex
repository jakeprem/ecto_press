defmodule EctoPress do
  @moduledoc """
  EctoPress is a library to easily generate context modules in Elixir.

  Using a simple DSL you can automatically generate the boilerplate for simple context functions.
  You can extend this behavior by providing your own resource provider.

  See the `EctoPress.DSL` module for more information.

  ## Examples
    ```elixir
    defmodule MyApp.MyContext do
      use EctoPress, repo: MyApp.Repo, resource_provider: MyApp.MyResourceProvider

      resource User, MyApp.User
      resource Post, MyApp.Post, plural: "articles", only: [:list, :get]
    end

    iex> MyContext.list_users()
    [%MyApp.User{}, ...]

    iex> MyContext.list_articles()
    [%MyApp.Post{}, ...]
    ```
  """

  @doc """
  Use this module to setup your context module.

  Delegates to `EctoPress.DSL`.

  ## Options
    - `:repo`: The repo to use for the resources. Defaults to the repo set in the DSL.
    - `:resource_provider`: The resource provider to use for the resources. Defaults to `EctoPress.BaseResourceProvider`. Must implement the `EctoPress.ResourceProvider` behaviour.

  ## Examples
    ```elixir
    defmodule MyApp.MyContext do
      use EctoPress, repo: MyApp.Repo, resource_provider: MyApp.MyResourceProvider

      resource User, MyApp.User
      resource Post, MyApp.Post, plural: "articles", only: [:list, :get]
    end
    ```
  """
  defmacro __using__(opts) do
    EctoPress.DSL.using_macro(opts)
  end
end
