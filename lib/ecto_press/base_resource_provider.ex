defmodule EctoPress.BaseResourceProvider do
  @moduledoc """
  Base implementation of the EctoPress.ResourceProvider behaviour.

  This module provides a basic implementation of the EctoPress.ResourceProvider
  behaviour that can be used as a starting point for custom resource providers.

  This module can be used as-is or used with `use EctoPress.BaseResourceProvider` to serve as a base for your own implementation.
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour EctoPress.ResourceProvider
      alias EctoPress.BaseResourceProvider

      @impl EctoPress.ResourceProvider
      def get(repo, schema, id, opts) do
        BaseResourceProvider.get(repo, schema, id, opts)
      end

      @impl EctoPress.ResourceProvider
      def fetch(repo, schema, id, opts) do
        BaseResourceProvider.fetch(repo, schema, id, opts)
      end

      @impl EctoPress.ResourceProvider
      def create(repo, schema, attrs, opts) do
        BaseResourceProvider.create(repo, schema, attrs, opts)
      end

      @impl EctoPress.ResourceProvider
      def update(repo, schema, resource, attrs, opts) do
        BaseResourceProvider.update(repo, schema, resource, attrs, opts)
      end

      @impl EctoPress.ResourceProvider
      def delete(repo, schema, resource, opts) do
        BaseResourceProvider.delete(repo, schema, resource, opts)
      end

      @impl EctoPress.ResourceProvider
      def list(repo, schema, opts) do
        BaseResourceProvider.list(repo, schema, opts)
      end

      @impl EctoPress.ResourceProvider
      def changeset(resource, attrs, opts) do
        BaseResourceProvider.changeset(resource, attrs, opts)
      end

      defoverridable EctoPress.ResourceProvider
    end
  end

  @behaviour EctoPress.ResourceProvider

  import Ecto.Query

  @impl true
  def get(repo, schema, id, _opts) do
    repo.get(schema, id)
  end

  @impl true
  def fetch(repo, schema, id, opts) do
    case get(repo, schema, id, opts) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  @impl true
  def create(repo, schema, attrs, _opts) do
    schema
    |> struct()
    |> schema.changeset(attrs)
    |> repo.insert()
  end

  @impl true
  def update(repo, schema, resource, attrs, _opts) do
    resource
    |> schema.changeset(attrs)
    |> repo.update()
  end

  @impl true
  def delete(repo, _schema, resource, _opts) do
    repo.delete(resource)
  end

  @impl true
  def list(repo, schema, opts) do
    schema
    |> apply_options(opts)
    |> repo.all()
  end

  @impl true
  def changeset(%schema{} = resource, attrs, _opts) do
    attrs = Map.new(attrs)
    schema.changeset(resource, attrs)
  end

  # Private helpers

  defp apply_options(query, opts) do
    Enum.reduce(opts, query, fn
      {:order_by, order}, query ->
        order_by(query, ^order)

      {:limit, limit}, query ->
        limit(query, ^limit)

      {:offset, offset}, query ->
        offset(query, ^offset)

      {:preload, preloads}, query ->
        preload(query, ^preloads)

      {:where, conditions}, query ->
        where(query, ^conditions)

      _opt, query ->
        query
    end)
  end
end
