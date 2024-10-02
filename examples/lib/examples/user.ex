defmodule Examples.User do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
