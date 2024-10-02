defmodule EctoPress do
  @moduledoc """
  Documentation for `EctoPress`.
  """

  defmacro __using__(opts) do
    EctoPress.DSL.using_macro(opts)
  end
end
