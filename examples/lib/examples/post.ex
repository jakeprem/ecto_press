defmodule Examples.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string
    belongs_to :user, Examples.User

    timestamps()
  end

  def changeset(%__MODULE__{} = post, attrs) do
    post
    |> cast(attrs, [:title, :body, :user_id])
    |> validate_required([:title, :body])
  end
end
