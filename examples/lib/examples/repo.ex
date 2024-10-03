defmodule Examples.Repo do
  use Ecto.Repo, otp_app: :examples, adapter: Ecto.Adapters.SQLite3
  @moduledoc """
  A simple Mock Ecto repository to demo EctoPress.

  When `Examples.list_users()` works with this repo, it demonstrates that
  the macros have generated correctly and called back into the repo.
  """
  # def get(schema, 1, _opts), do: struct(schema, id: 1, name: "Test")
  # def get(_schema, _id, _opts), do: nil

  # def get!(schema, 1, _opts), do: struct(schema, id: 1, name: "Test")
  # def get!(_schema, _id, _opts), do: raise("NO RESULTS")

  # def get_by(schema, [id: 1], _opts), do: struct(schema, id: 1, name: "Test")
  # def get_by(_schema, _clauses, _opts), do: nil

  # def get_by!(schema, [id: 1], _opts), do: struct(schema, id: 1, name: "Test")
  # def get_by!(_schema, _clauses, _opts), do: raise("NO RESULTS")

  # def all(schema, _opts \\ []),
  #   do: [struct(schema, id: 1, name: "Test"), struct(schema, id: 2, name: "Test 2")]

  # def insert(%Ecto.Changeset{valid?: true, changes: changes, data: %schema{}}, _opts) do
  #   {:ok, struct(schema, changes)}
  # end

  # def insert(changeset, _opts), do: {:error, changeset}

  # def one(%{schema: schema}, _opts), do: struct(schema, id: 1, name: "Test")
  # def one(_schema, _opts), do: nil

  # def update(%Ecto.Changeset{valid?: true, changes: changes, data: %schema{}}, _opts) do
  #   {:ok, struct(schema, changes)}
  # end

  # def update(changeset, _opts), do: {:error, changeset}

  # def delete(resource, _opts), do: {:ok, resource}
end
