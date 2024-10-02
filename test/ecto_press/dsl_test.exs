defmodule EctoPress.DSLTest do
  use ExUnit.Case, async: true

  alias EctoPress.Test.MockRepo
  alias EctoPress.Test.MockSchema

  defmodule TestContext do
    use EctoPress.DSL, repo: MockRepo

    resource :user, MockSchema
    resource :post, MockSchema, plural: "articles", only: [:get, :fetch, :list]
    resource :comment, MockSchema, except: [:delete]
  end

  describe "get/1" do
    test "get_user returns the entity when found" do
      assert %MockSchema{id: 1, name: "Test"} = TestContext.get_user(1)
    end

    test "get_user returns nil when not found" do
      assert is_nil(TestContext.get_user(2))
    end
  end

  describe "fetch/1" do
    test "fetch_user returns ok tuple when found" do
      assert {:ok, %MockSchema{id: 1, name: "Test"}} = TestContext.fetch_user(1)
    end

    test "fetch_user returns error tuple when not found" do
      assert {:error, :not_found} = TestContext.fetch_user(2)
    end
  end

  describe "create/1" do
    test "create_user with valid attributes" do
      assert {:ok, %MockSchema{name: "New User"}} = TestContext.create_user(%{name: "New User"})
    end

    test "create_user with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = TestContext.create_user(%{})
    end
  end

  describe "list/0" do
    test "list_users returns all users" do
      assert [%MockSchema{}, %MockSchema{}] = TestContext.list_users()
    end
  end

  describe "update/1" do
    test "update_user with valid attributes" do
      user = %MockSchema{id: 1, name: "Old Name"}

      assert {:ok, %MockSchema{id: 1, name: "New Name"}} =
               TestContext.update_user(user, %{name: "New Name"})
    end

    test "update_user with invalid attributes" do
      user = %MockSchema{id: 1, name: "Old Name"}
      assert {:error, %Ecto.Changeset{}} = TestContext.update_user(user, %{name: nil})
    end
  end

  describe "delete/1" do
    test "delete_user" do
      user = %MockSchema{id: 1, name: "Test"}
      assert {:ok, %MockSchema{id: 1, name: "Test"}} = TestContext.delete_user(user)
    end
  end

  describe "changeset/1" do
    test "user_changeset" do
      changeset = TestContext.user_changeset(%{name: "New User"})
      assert %Ecto.Changeset{valid?: true, changes: %{name: "New User"}} = changeset
    end
  end

  describe "change/1" do
    test "user_change" do
      user = %MockSchema{id: 1, name: "Test"}
      change = TestContext.change_user(user, %{name: "New User"})
      assert %Ecto.Changeset{valid?: true, changes: %{name: "New User"}} = change
    end
  end

  describe "resource options" do
    test "respects custom plural name" do
      assert function_exported?(TestContext, :list_articles, 0)
      refute function_exported?(TestContext, :list_posts, 0)
    end

    test "generates all functions by default" do
      assert function_exported?(TestContext, :get_user, 1)
      assert function_exported?(TestContext, :fetch_user, 1)
      assert function_exported?(TestContext, :list_users, 0)
      assert function_exported?(TestContext, :create_user, 1)
      assert function_exported?(TestContext, :update_user, 2)
      assert function_exported?(TestContext, :delete_user, 1)
      assert function_exported?(TestContext, :change_user, 2)
      assert function_exported?(TestContext, :user_changeset, 1)
    end

    test "respects :only option" do
      # get, fetch, and lis are in only
      assert function_exported?(TestContext, :get_post, 1)
      assert function_exported?(TestContext, :fetch_post, 1)
      assert function_exported?(TestContext, :list_articles, 0)
      # the rest are not in only
      refute function_exported?(TestContext, :create_post, 1)
      refute function_exported?(TestContext, :update_post, 2)
      refute function_exported?(TestContext, :delete_post, 1)
      refute function_exported?(TestContext, :change_post, 2)
      refute function_exported?(TestContext, :post_changeset, 1)
    end

    test "respects :except option" do
      assert function_exported?(TestContext, :get_comment, 1)
      assert function_exported?(TestContext, :fetch_comment, 1)
      assert function_exported?(TestContext, :list_comments, 0)
      assert function_exported?(TestContext, :create_comment, 1)
      assert function_exported?(TestContext, :update_comment, 2)
      assert function_exported?(TestContext, :change_comment, 2)
      assert function_exported?(TestContext, :comment_changeset, 1)
      # delete is excepted
      refute function_exported?(TestContext, :delete_comment, 1)
    end
  end

  describe "reflectoin functions" do
    test "__resources__/0 returns list of registered resources" do
      resources = TestContext.__resources__()
      assert length(resources) == 3
      assert Enum.any?(resources, &(&1.name == :user))
      assert Enum.any?(resources, &(&1.name == :post and &1.plural == "articles"))
      assert Enum.any?(resources, &(&1.name == :comment and &1.opts == [except: [:delete]]))
    end

    test "__resource__/1 returns resource struct when found" do
      assert resource = TestContext.__resource__(:user)
      assert resource.name == :user
      assert resource.schema == MockSchema
    end

    test "__resource__/1 raises on invalid resource access" do
      assert_raise RuntimeError, "Resource invalid not found", fn ->
        TestContext.__resource__(:invalid)
      end
    end
  end
end
