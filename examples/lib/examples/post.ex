defmodule Examples.Post do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
  end

  def changeset(%__MODULE__{} = post, attrs) do
    post
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
