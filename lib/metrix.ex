defmodule Metrix do
  @moduledoc """
  Metrix is a library to log custom application metrics, in a well-structured,
  human *and* machine readable format, for use by downstream log processing
  systems (like Librato, Riemann, etc...).
  """

  use Application
  require Logger

  alias Metrix.Context
  alias Metrix.Modifiers

  @impl Application
  def start(_type, _args) do
    children = [
      {Context, initial_context()},
      {Modifiers, initial_modifiers()}
    ]

    opts = [strategy: :one_for_one, name: Metrix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp initial_context do
    case Application.get_env(:metrix, :context) do
      nil -> %{}
      context -> context
    end
  end

  defp initial_modifiers do
    case Application.get_env(:metrix, :prefix) do
      nil -> %{}
      prefix -> %{prefix: prefix}
    end
  end

  @doc """
  Adds `metadata` to the global context, which will add the metadata values
  to all subsequent metrix output. Global context is useful for component-wide
  values, such as source=X or app=Y metadata, that remains unchanged throughout
  the life of your application.
  """
  @spec add_context(map() | keyword()) :: :ok
  def add_context(metadata), do: Context.put(metadata)

  @spec get_context() :: map()
  def get_context, do: Context.get()

  @spec clear_context() :: :ok
  def clear_context, do: Context.clear()

  @doc """
  The `prefix` is prepended to the name of the metric.
  """
  @spec put_prefix(String.t()) :: :ok
  def put_prefix(prefix), do: Modifiers.put_prefix(prefix)

  @spec clear_prefix() :: :ok
  def clear_prefix, do: Modifiers.clear_prefix()

  @spec count(String.t() | atom()) :: map()
  def count(metric), do: count(metric, 1)
  def count(metric, num) when is_number(num), do: count(%{}, metric, num)
  def count(metadata, metric), do: count(metadata, metric, 1)

  @spec count(map() | keyword(), String.t() | atom(), number()) :: map() | keyword()
  def count(metadata, metric, num) do
    log(format_metric("count", metric, num), metadata)
    metadata
  end

  @spec sample(String.t() | atom(), term()) :: map()
  def sample(metric, value), do: sample(%{}, metric, value)

  @spec sample(map() | keyword(), String.t() | atom(), term()) :: map() | keyword()
  def sample(metadata, metric, value) do
    log(format_metric("sample", metric, value), metadata)
    metadata
  end

  @spec measure(String.t() | atom(), number() | function()) :: term()
  def measure(metric, ms) when is_number(ms), do: measure(%{}, metric, ms)
  def measure(metric, fun) when is_function(fun), do: measure(%{}, metric, fun)

  @spec measure(map() | keyword(), String.t() | atom(), number() | function()) :: term()
  def measure(metadata, metric, ms) when is_number(ms) do
    log(format_metric("measure", metric, "#{ms}ms"), metadata)
    metadata
  end

  def measure(metadata, metric, fun) when is_function(fun) do
    {service_us, ret_value} =
      cond do
        is_function(fun, 0) -> :timer.tc(fun)
        is_function(fun, 1) -> :timer.tc(fun, [metadata])
      end

    log(format_metric("measure", metric, "#{service_us / 1000}ms"), metadata)

    ret_value
  end

  defp format_metric(type, metric, value) do
    Logfmt.encode(%{prefix_metric(type, metric) => value})
  end

  defp log(formatted_metric, metadata) do
    metadata_with_context =
      metadata
      |> Enum.into(%{})
      |> Map.merge(get_context())
      |> Logfmt.encode()

    write("#{formatted_metric} #{metadata_with_context}")
  end

  defp prefix_metric(type, metric) do
    case Modifiers.get_prefix() do
      nil -> "#{type}##{metric}"
      prefix -> "#{type}##{prefix}#{metric}"
    end
  end

  defp write(output), do: Logger.info(output)
end
