defmodule EctoPress.Test.MockSchema do
  @moduledoc """
  Simple mock schema for testing.
  """

  use Ecto.Schema

  import Ecto.Changeset

  schema "mock_schemas" do
    field(:name, :string)
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
