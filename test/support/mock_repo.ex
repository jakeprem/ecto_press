defmodule EctoPress.Test.MockRepo do
  @moduledoc """
  Simple mock repo for testing.

  Lets us avoid more complex database dependencies in tests.
  """

  alias EctoPress.Test.MockSchema

  def get(MockSchema, 1), do: %MockSchema{id: 1, name: "Test"}
  def get(MockSchema, _), do: nil

  def all(MockSchema),
    do: [%MockSchema{id: 1, name: "Test"}, %MockSchema{id: 2, name: "Test 2"}]

  def insert(%Ecto.Changeset{valid?: true, changes: changes}) do
    {:ok, struct(MockSchema, changes)}
  end

  def insert(changeset), do: {:error, changeset}

  def one(%{schema: MockSchema}), do: %MockSchema{id: 1, name: "Test"}
  def one(_), do: nil

  def update(%Ecto.Changeset{valid?: true, changes: changes, data: data}) do
    {:ok, struct(data, changes)}
  end

  def update(changeset), do: {:error, changeset}

  def delete(%MockSchema{} = schema) do
    {:ok, schema}
  end
end
