defmodule Examples.AuthorizedProvider do
  use EctoPress.BaseResourceProvider

  @moduledoc """
  An authorized resource provider for EctoPress.

  An example of overriding the defaults.
  """

  def authorize(resource, action, context) do
    case {resource, action, context} do
      {_, _, %{role: :admin}} -> :authorized
      _ -> :unauthorized
    end
  end

  def get(repo, schema, id, opts) do
    with :authorized <- authorize(schema, :get, opts[:context]) do
      super(repo, schema, id, opts)
    end
  end

  def fetch(repo, schema, id, opts) do
    case authorize(schema, :fetch, opts[:context]) do
      :unauthorized -> {:error, :unauthorized}
      :authorized -> super(repo, schema, id, opts)
    end
  end

  def create(repo, schema, attrs, opts) do
    case authorize(schema, :create, opts[:context]) do
      :unauthorized -> {:error, :unauthorized}
      :authorized -> super(repo, schema, attrs, opts)
    end
  end

  def update(repo, schema, resource, attrs, opts) do
    case authorize(schema, :update, opts[:context]) do
      :unauthorized -> {:error, :unauthorized}
      :authorized -> super(repo, schema, resource, attrs, opts)
    end
  end

  def delete(repo, schema, resource, opts) do
    case authorize(schema, :delete, opts[:context]) do
      :unauthorized -> {:error, :unauthorized}
      :authorized -> super(repo, schema, resource, opts)
    end
  end

  def list(repo, schema, opts) do
    case authorize(schema, :list, opts[:context]) do
      :unauthorized -> {:error, :unauthorized}
      :authorized -> super(repo, schema, opts)
    end
  end
end
