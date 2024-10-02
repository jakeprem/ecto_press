defmodule EctoPress.BaseResourceProviderTest do
  use ExUnit.Case

  alias EctoPress.BaseResourceProvider
  alias EctoPress.Test.MockRepo
  alias EctoPress.Test.MockSchema

  import ExUnit.CaptureLog

  describe "get/4" do
    test "returns the resource when found" do
      assert %MockSchema{id: 1, name: "Test"} =
               BaseResourceProvider.get(MockRepo, MockSchema, 1, [])
    end

    test "returns nil when not found" do
      assert is_nil(BaseResourceProvider.get(MockRepo, MockSchema, 2, []))
    end
  end

  describe "fetch/4" do
    test "returns {:ok, resource} when found" do
      assert {:ok, %MockSchema{id: 1, name: "Test"}} =
               BaseResourceProvider.fetch(MockRepo, MockSchema, 1, [])
    end

    test "returns {:error, :not_found} when not found" do
      assert {:error, :not_found} = BaseResourceProvider.fetch(MockRepo, MockSchema, 2, [])
    end
  end

  describe "create/4" do
    test "returns {:ok, resource} when successful" do
      assert {:ok, %MockSchema{name: "New User"}} =
               BaseResourceProvider.create(MockRepo, MockSchema, %{name: "New User"}, [])
    end

    test "returns {:error, changeset} when unsuccessful" do
      assert {:error, %Ecto.Changeset{}} =
               BaseResourceProvider.create(MockRepo, MockSchema, %{}, [])
    end
  end

  describe "update/5" do
    test "returns {:ok, resource} when successful" do
      assert {:ok, %MockSchema{name: "Updated User"}} =
               BaseResourceProvider.update(
                 MockRepo,
                 MockSchema,
                 %MockSchema{id: 1},
                 %{name: "Updated User"},
                 []
               )
    end
  end

  describe "delete/4" do
    test "returns {:ok, resource} when successful" do
      assert {:ok, %MockSchema{}} =
               BaseResourceProvider.delete(MockRepo, MockSchema, %MockSchema{id: 1}, [])
    end
  end

  describe "list/3" do
    test "returns all resources" do
      assert [%MockSchema{}, %MockSchema{}] = BaseResourceProvider.list(MockRepo, MockSchema, [])
    end
  end

  describe "changeset/3" do
    test "returns a changeset" do
      assert %Ecto.Changeset{data: %MockSchema{}} =
               BaseResourceProvider.changeset(%MockSchema{}, %{name: "New User"}, [])
    end
  end

  describe "__using__macro" do
    defmodule TestProvider do
      use EctoPress.BaseResourceProvider
    end

    test "using defines all callback functions" do
      callbacks = EctoPress.ResourceProvider.behaviour_info(:callbacks)

      for {callback, arity} <- callbacks do
        assert function_exported?(TestProvider, callback, arity)
      end
    end

    defmodule OverwrittenProvider do
      use EctoPress.BaseResourceProvider
      require Logger

      def get(repo, schema, id, opts) do
        Logger.info("__macro_test__")
        super(repo, schema, id, opts)
      end

      def create(_repo, _schema, _attrs, _opts) do
        {:ok, :custom_create}
      end
    end

    # should probably be separate tests but eh
    test "allows overriding callback functions" do
      assert function_exported?(OverwrittenProvider, :create, 4)
      assert function_exported?(OverwrittenProvider, :get, 4)

      assert {:ok, :custom_create} = OverwrittenProvider.create(MockRepo, MockSchema, %{}, [])

      assert capture_log(fn ->
               %MockSchema{} = OverwrittenProvider.get(MockRepo, MockSchema, 1, [])
             end) =~ "__macro_test__"

      # non-overridden callbacks still work
      assert {:ok, %MockSchema{}} = OverwrittenProvider.fetch(MockRepo, MockSchema, 1, [])
    end
  end
end
