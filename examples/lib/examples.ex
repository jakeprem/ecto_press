defmodule Examples do
  @moduledoc """
  EctoPress examples.
  """
  use EctoPress.DSL, repo: Examples.Repo
  resource :user, Examples.User

  resource :user_authorized, Examples.User,
    resource_provider: Examples.AuthorizedProvider,
    plural: "users_authorized"

  resource :post_custom, Examples.Post,
    plural: "posts_custom",
    resource_provider: Examples.CustomProvider

  resource :post_evented, Examples.Post,
    plural: "posts_evented",
    resource_provider: Examples.EventedProvider
end
