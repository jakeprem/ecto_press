defmodule Examples.EventedProvider do
  @moduledoc """
  An example of a resource provider that "emits" events.
  """
  use EctoPress.BaseResourceProvider

  require Logger

  def emit_event(event, resource) do
    event_name =
      event
      |> to_string()
      |> String.capitalize()

    Logger.info("Event: #{event_name} #{resource.__struct__}")
  end

  def create(repo, schema, attrs, opts) do
    with {:ok, resource} <- super(repo, schema, attrs, opts) do
      emit_event(:created, resource)
      {:ok, resource}
    end
  end

  def update(repo, schema, resource, attrs, opts) do
    with {:ok, resource} <- super(repo, schema, resource, attrs, opts) do
      emit_event(:updated, resource)
      {:ok, resource}
    end
  end

  def delete(repo, schema, resource, opts) do
    with {:ok, resource} <- super(repo, schema, resource, opts) do
      emit_event(:deleted, resource)
      {:ok, resource}
    end
  end
end
