defmodule Metrix.Context do
  @moduledoc """
  Holds the global logging context merged into every metric line.
  """

  use Agent

  @doc """
  Starts a new context.
  """
  @spec start_link(map() | keyword()) :: Agent.on_start()
  def start_link(initial_context) when is_list(initial_context) do
    Enum.into(initial_context, %{}) |> start_link()
  end

  def start_link(initial_context) when is_map(initial_context) do
    Agent.start_link(fn -> initial_context end, name: __MODULE__)
  end

  @doc """
  Gets current context.
  """
  @spec get() :: map()
  def get do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Adds the `metadata` to the context.
  """
  @spec put(map() | keyword()) :: :ok
  def put(metadata) when is_list(metadata), do: Enum.into(metadata, %{}) |> put()

  def put(metadata) when is_map(metadata) do
    Agent.update(__MODULE__, &Map.merge(&1, metadata))
  end

  @doc """
  Clears the existing context.
  """
  @spec clear() :: :ok
  def clear do
    Agent.update(__MODULE__, fn _metadata -> %{} end)
  end
end
