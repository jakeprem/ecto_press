defmodule Examples.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    has_many :posts, Examples.Post

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:name])
    |> cast_assoc(:posts)
    |> validate_required([:name])
  end
end
