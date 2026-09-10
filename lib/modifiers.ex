defmodule Metrix.Modifiers do
  @moduledoc """
  Holds modifiers applied to every metric, such as the global prefix.

  This could hold any modifiers. Perhaps a more generic approach would
  be to allow the configuration of each metric format.

  This could be merged into the Metrix.Context by giving the context a
  namespace within the map.
  """

  use Agent

  @doc """
  Starts the agent.
  """
  @spec start_link(map()) :: Agent.on_start()
  def start_link(initial_modifiers) do
    Agent.start_link(fn -> initial_modifiers end, name: __MODULE__)
  end

  @doc """
  Gets the metric prefix.
  """
  @spec get_prefix() :: String.t() | nil
  def get_prefix do
    Agent.get(__MODULE__, &Map.get(&1, :prefix))
  end

  @doc """
  Sets the metric prefix.
  """
  @spec put_prefix(String.t()) :: :ok
  def put_prefix(prefix) do
    Agent.update(__MODULE__, &Map.put(&1, :prefix, prefix))
  end

  @doc """
  Clears the metric prefix.
  """
  @spec clear_prefix() :: :ok
  def clear_prefix do
    Agent.update(__MODULE__, &Map.delete(&1, :prefix))
  end
end
