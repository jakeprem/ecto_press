defmodule EctoPress.DSL do
  @moduledoc """
  DSL for defining resources and generating context functions.
  """

  @doc """
  Use this module to setup your context module.

  ## Options
    - `:repo`: The repo to use for the resources.
    - `:resource_provider`: The resource provider to use for the resources. Defaults to `EctoPress.BaseResourceProvider`. Must implement the `EctoPress.ResourceProvider` behaviour.
  """
  defmacro __using__(opts), do: using_macro(opts)

  @doc false
  def using_macro(opts) do
    quote do
      import EctoPress.DSL
      @before_compile EctoPress.DSL
      Module.register_attribute(__MODULE__, :ecto_press_resources, accumulate: true)
      @ecto_press_opts unquote(opts)
    end
  end

  @doc """
  Define a resource to have context functions generated for it.

  ## Options

    - `:plural`: The plural name of the resource. Defaults to the pluralized form of the name.
    - `:repo`: The repo to use for the resource. Defaults to the repo set in the DSL.
    - `:resource_provider`: The resource provider to use for the resource. Defaults to the resource provider set in the DSL. Must implement the `EctoPress.ResourceProvider` behaviour.
  """
  defmacro resource(name, schema, opts \\ []) do
    quote do
      @ecto_press_resources {unquote(name), unquote(schema), unquote(opts)}
    end
  end

  defmacro __before_compile__(env) do
    resources = Module.get_attribute(env.module, :ecto_press_resources)
    global_opts = Module.get_attribute(env.module, :ecto_press_opts)

    reflection_functions = generate_reflection_functions(resources)
    function_definitions = generate_functions(resources, global_opts)

    quote do
      unquote(reflection_functions)
      unquote(function_definitions)
    end
  end

  def generate_reflection_functions(resources) do
    resources_list =
      for {name, schema, opts} <- resources do
        plural = opts[:plural] || Inflex.pluralize(name)
        %{name: name, plural: plural, schema: schema, opts: opts}
      end

    resource_functions =
      for resource <- resources_list do
        quote do
          def __resource__(unquote(resource.name)) do
            unquote(Macro.escape(resource))
          end
        end
      end

    quote do
      def __resources__ do
        unquote(Macro.escape(resources_list))
      end

      unquote(resource_functions)

      def __resource__(name), do: raise("Resource #{name} not found")
    end
  end

  def generate_functions(resources, global_opts) do
    global_resource_provider = global_opts[:resource_provider] || EctoPress.BaseResourceProvider
    global_repo = global_opts[:repo]

    for {name, schema, resource_opts} <- resources do
      resource_provider = resource_opts[:resource_provider] || global_resource_provider
      repo = resource_opts[:repo] || global_repo
      plural_name = resource_opts[:plural] || Inflex.pluralize(name)

      functions_to_generate = get_functions_to_generate(resource_opts)

      for function_name <- functions_to_generate do
        generate_function(
          function_name,
          name,
          plural_name,
          schema,
          repo,
          resource_provider,
          resource_opts
        )
      end
    end
  end

  defp get_functions_to_generate(opts) do
    default_functions = [
      :get,
      :get!,
      :get_by,
      :get_by!,
      :fetch,
      :fetch_by,
      :create,
      :update,
      :delete,
      :list,
      :changeset,
      :change
    ]

    cond do
      opts[:only] -> Enum.filter(default_functions, &(&1 in opts[:only]))
      opts[:except] -> default_functions -- opts[:except]
      true -> default_functions
    end
  end

  defp generate_function(
         :get,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Gets a single #{unquote(name)} by ID.

      ## Parameters

        - id: The ID of the #{unquote(name)} to retrieve.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.get/4` for available options.

      ## Returns

        - The #{unquote(schema)} struct if found.
        - nil if not found or not authorized.

      ## Examples

          iex> get_#{unquote(name)}(1)
          %#{unquote(schema)}{id: 1, ...}

          iex> get_#{unquote(name)}(1, [option: value])
          %#{unquote(schema)}{id: 1, ...}
      """
      def unquote(:"get_#{name}")(id, opts \\ []) do
        unquote(resource_provider).get(unquote(repo), unquote(schema), id, opts)
      end
    end
  end

  defp generate_function(
         :get!,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Gets a single #{unquote(name)} by ID.

      Raises if not found. See `#{unquote(resource_provider)}.get!/3` and `#{unquote(repo)}.get!/3` for more information.

      ## Parameters

        - id: The ID of the #{unquote(name)} to retrieve.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.get/4` for available options.

      ## Returns

        - The #{unquote(schema)} struct if found.
        - Raises if not found.

      ## Examples

          iex> get_#{unquote(name)}(1)
          %#{unquote(schema)}{id: 1, ...}
      """
      def unquote(:"get_#{name}!")(id, opts \\ []) do
        unquote(resource_provider).get!(unquote(repo), unquote(schema), id, opts)
      end
    end
  end

  defp generate_function(
         :get_by,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Retrieves a single #{unquote(name)} by the provided opts.

      ## Parameters
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.get_by/3` and `#{unquote(repo)}.get_by/3` for available options.

      ## Returns

        - The #{unquote(schema)} struct if found.
        - nil if not found or not authorized.

      ## Examples

          iex> get_#{unquote(name)}_by([option: value])
          %#{unquote(schema)}{...}

          iex> get_#{unquote(name)}_by([option: value])
          %#{unquote(schema)}{...}
      """
      def unquote(:"get_#{name}_by")(clauses, opts \\ []) do
        unquote(resource_provider).get_by(unquote(repo), unquote(schema), clauses, opts)
      end
    end
  end

  defp generate_function(
         :get_by!,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Retrieves a single #{unquote(name)} by the provided opts.

      Raises if not found. See `#{unquote(resource_provider)}.get_by!/3` and `#{unquote(repo)}.get_by!/2` for more information.

      ## Parameters
        - clauses: A keyword list of query clauses.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.get_by/3` for available options.

      ## Returns

        - The #{unquote(schema)} struct if found.
        - Raises if not found.

      ## Examples

          iex> get_#{unquote(name)}_by!([option: value])
          %#{unquote(schema)}{...}
      """
      def unquote(:"get_#{name}_by!")(clauses, opts \\ []) do
        unquote(resource_provider).get_by!(unquote(repo), unquote(schema), clauses, opts)
      end
    end
  end

  defp generate_function(
         :fetch,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Fetches a single #{unquote(name)} by ID.

      ## Parameters

        - id: The ID of the #{unquote(name)} to fetch.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.fetch/4` for available options.

      ## Returns

        - `{:ok, #{unquote(schema)}}` if the #{unquote(name)} was found.
        - `{:error, :not_found}` if the #{unquote(name)} was not found.
        - Other error tuples as defined in `#{unquote(resource_provider)}.fetch/4`.

      ## Examples

          iex> fetch_#{unquote(name)}(1)
          {:ok, %#{unquote(schema)}{id: 1, ...}}

          iex> fetch_#{unquote(name)}(1, [option: value])
          {:ok, %#{unquote(schema)}{id: 1, ...}}
      """
      def unquote(:"fetch_#{name}")(id, opts \\ []) do
        unquote(resource_provider).fetch(unquote(repo), unquote(schema), id, opts)
      end
    end
  end

  defp generate_function(
         :fetch_by,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Fetches a single #{unquote(name)} by the provided opts.

      ## Parameters
        - clauses: A keyword list of query clauses.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.fetch_by/3` for available options.

      ## Returns

        - `{:ok, #{unquote(schema)}}` if the #{unquote(name)} was found.
        - `{:error, :not_found}` if the #{unquote(name)} was not found.
        - Other error tuples as defined in `#{unquote(resource_provider)}.fetch_by/3`.

      ## Examples

          iex> fetch_#{unquote(name)}_by([option: value])
          {:ok, %#{unquote(schema)}{...}}

          iex> fetch_#{unquote(name)}_by([option: value])
          {:error, :not_found}
      """
      def unquote(:"fetch_#{name}_by")(clauses, opts \\ []) do
        unquote(resource_provider).fetch_by(unquote(repo), unquote(schema), clauses, opts)
      end
    end
  end

  defp generate_function(
         :create,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Creates a new #{unquote(name)}.

      ## Parameters

        - attrs: A map of attributes for the new #{unquote(name)}.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.create/4` for available options.

      ## Returns

        - `{:ok, #{unquote(schema)}}` if the #{unquote(name)} was created successfully.
        - `{:error, Ecto.Changeset.t()}` if there was a validation error.
        - Other error tuples as defined in `#{unquote(resource_provider)}.create/4`.

      ## Examples

          iex> create_#{unquote(name)}(%{field: value})
          {:ok, %#{unquote(schema)}{}}

          iex> create_#{unquote(name)}(%{field: value}, [option: value])
          {:ok, %#{unquote(schema)}{}}
      """
      def unquote(:"create_#{name}")(attrs, opts \\ []) do
        unquote(resource_provider).create(unquote(repo), unquote(schema), attrs, opts)
      end
    end
  end

  defp generate_function(
         :update,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Updates an existing #{unquote(name)}.

      ## Parameters

        - #{unquote(name)}: The #{unquote(name)} struct to update.
        - attrs: A map of attributes to update.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.update/5` for available options.

      ## Returns

        - `{:ok, #{unquote(schema)}}` if the #{unquote(name)} was updated successfully.
        - `{:error, Ecto.Changeset.t()}` if there was a validation error.
        - Other error tuples as defined in `#{unquote(resource_provider)}.update/5`.

      ## Examples

          iex> update_#{unquote(name)}(#{unquote(name)}, %{field: new_value})
          {:ok, %#{unquote(schema)}{}}

          iex> update_#{unquote(name)}(#{unquote(name)}, %{field: new_value}, [option: value])
          {:ok, %#{unquote(schema)}{}}
      """
      def unquote(:"update_#{name}")(resource, attrs, opts \\ []) do
        unquote(resource_provider).update(
          unquote(repo),
          unquote(schema),
          resource,
          attrs,
          opts
        )
      end
    end
  end

  defp generate_function(
         :delete,
         name,
         _plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Deletes a #{unquote(name)}.

      ## Parameters

        - #{unquote(name)}: The #{unquote(name)} struct to delete.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.delete/4` for available options.

      ## Returns

        - `{:ok, #{unquote(schema)}}` if the #{unquote(name)} was deleted successfully.
        - `{:error, Ecto.Changeset.t()}` if there was an error during deletion.
        - Other error tuples as defined in `#{unquote(resource_provider)}.delete/4`.

      ## Examples

          iex> delete_#{unquote(name)}(#{unquote(name)})
          {:ok, %#{unquote(schema)}{}}

          iex> delete_#{unquote(name)}(#{unquote(name)}, [option: value])
          {:ok, %#{unquote(schema)}{}}
      """
      def unquote(:"delete_#{name}")(resource, opts \\ []) do
        unquote(resource_provider).delete(unquote(repo), unquote(schema), resource, opts)
      end
    end
  end

  defp generate_function(
         :list,
         _name,
         plural_name,
         schema,
         repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Lists #{unquote(plural_name)}.

      ## Parameters
        - clauses: A keyword list of clauses to be applied to the query. See `#{unquote(resource_provider)}.list/3` for available options.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.list/3` for available options.

      ## Returns

        - A list of #{unquote(schema)} structs.

      ## Examples

          iex> list_#{unquote(plural_name)}()
          [%#{unquote(schema)}{}, ...]

          iex> list_#{unquote(plural_name)}([option: value])
          [%#{unquote(schema)}{}, ...]
      """
      def unquote(:"list_#{plural_name}")(clauses \\ [], opts \\ []) do
        unquote(resource_provider).list(unquote(repo), unquote(schema), clauses, opts)
      end
    end
  end

  defp generate_function(
         :changeset,
         name,
         _plural_name,
         schema,
         _repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Creates a blank changeset for a #{unquote(name)}.

      Basically the same as `change_#{unquote(name)}/2` but defaults the blank struct for you so you can have a nice `#{unquote(name)}_changeset(attrs)` functionality.


      ## Parameters

        - #{unquote(name)}: The #{unquote(name)} struct to create a changeset for. If not provided, a new struct is created.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.changeset/4` for available options.

      ## Returns

        - A blank `Ecto.Changeset` for the #{unquote(name)}.

      ## Examples

          iex> #{unquote(name)}_changeset()
          #Ecto.Changeset<...>

          iex> #{unquote(name)}_changeset(%{name: "John"}, option: value)
          #Ecto.Changeset<...>
      """
      def unquote(:"#{name}_changeset")(attrs \\ %{}, opts \\ []) do
        unquote(resource_provider).changeset(struct(unquote(schema)), attrs, opts)
      end
    end
  end

  defp generate_function(
         :change,
         name,
         _plural_name,
         _schema,
         _repo,
         resource_provider,
         _resource_opts
       ) do
    quote location: :keep do
      @doc """
      Creates a changeset for a #{unquote(name)} with the given changes.

      ## Parameters

        - #{unquote(name)}: The #{unquote(name)} struct to create a changeset for.
        - opts: A keyword list of options. See `#{unquote(resource_provider)}.changeset/4` for available options.

      ## Returns

        - An `Ecto.Changeset` for the #{unquote(name)}.

      ## Examples

          iex> #{unquote(name)}_changeset(%{name: "John"})
          #Ecto.Changeset<...>

          iex> #{unquote(name)}_changeset(%{name: "John}, option: value)
          #Ecto.Changeset<...>
      """
      def unquote(:"change_#{name}")(
            resource,
            attrs \\ %{},
            opts \\ []
          ) do
        unquote(resource_provider).changeset(resource, attrs, opts)
      end
    end
  end
end
