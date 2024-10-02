defmodule Examples.Repo do
  @moduledoc """
  A simple Mock Ecto repository to demo EctoPress.

  When `Examples.list_users()` works with this repo, it demonstrates that
  the macros have generated correctly and called back into the repo.
  """
  def get(schema, 1), do: struct(schema, id: 1, name: "Test")
  def get(_schema, _), do: nil

  def all(schema),
    do: [struct(schema, id: 1, name: "Test"), struct(schema, id: 2, name: "Test 2")]

  def insert(%Ecto.Changeset{valid?: true, changes: changes, data: %schema{}}) do
    {:ok, struct(schema, changes)}
  end

  def insert(changeset), do: {:error, changeset}

  def one(%{schema: schema}), do: struct(schema, id: 1, name: "Test")
  def one(_), do: nil

  def update(%Ecto.Changeset{valid?: true, changes: changes, data: %schema{}}) do
    {:ok, struct(schema, changes)}
  end

  def update(changeset), do: {:error, changeset}

  def delete(resource) do
    {:ok, resource}
  end
end
