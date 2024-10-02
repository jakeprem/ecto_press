defmodule EctoPress.ResourceProvider do
  @moduledoc """
  Defines the behaviour for custom resource providers in EctoPress.

  Implement this behaviour to create custom resource modules that can be used
  with the EctoPress library. This allows for fine-grained control over how
  CRUD operations are performed for each resource.
  """

  @type schema :: struct()
  @type changeset :: Ecto.Changeset.t()
  @type id :: term()
  @type attrs :: map()
  @type opts :: keyword()

  @doc """
  Retrieves a single record by its ID.
  """
  @callback get(repo :: module(), schema :: module(), id(), opts()) ::
              schema() | nil

  @doc """
  Fetches a single record by its ID, returning an ok or error tuple.
  """
  @callback fetch(repo :: module(), schema :: module(), id(), opts()) ::
              {:ok, schema()} | {:error, :not_found | atom()}

  @doc """
  Creates a new record.
  """
  @callback create(repo :: module(), schema :: module(), attrs(), opts()) ::
              {:ok, schema()} | {:error, changeset() | atom()}

  @doc """
  Updates an existing record.
  """
  @callback update(repo :: module(), schema :: module(), schema(), attrs(), opts()) ::
              {:ok, schema()} | {:error, changeset() | atom()}

  @doc """
  Deletes an existing record.
  """
  @callback delete(repo :: module(), schema :: module(), schema(), opts()) ::
              {:ok, schema()} | {:error, changeset() | atom()}

  @doc """
  Lists records with options for filtering, sorting, and pagination.
  """
  @callback list(repo :: module(), schema :: module(), opts()) ::
              [schema()]

  @doc """
  Creates a changeset for the given schema and attributes.
  """
  @callback changeset(schema :: struct(), attrs :: attrs(), opts :: opts()) ::
              changeset()

  @optional_callbacks [
    get: 4,
    fetch: 4,
    create: 4,
    update: 5,
    delete: 4,
    list: 3,
    changeset: 3
  ]
end
