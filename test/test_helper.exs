ExUnit.start()

ExUnit.configure(exclude: [:config])

defmodule MetrixTestHelper do
  import ExUnit.CaptureLog

  def line(fun), do: capture_log(fun) |> String.trim()
  def silence(fun), do: capture_log(fun) && nil

  def matches_measure?(output, event), do: matches_measure?(output, event, "")

  def matches_measure?(output, event, prefix) do
    Regex.match?(~r/^measure##{prefix}#{event}=[0-9]+\.*+[0-9]+ms/u, output)
  end

  def matches_count?(output, event), do: matches_count?(output, event, "")

  def matches_count?(output, event, prefix) do
    Regex.match?(~r/^count##{prefix}#{event}=[0-9]+/u, output)
  end

  def matches_sample?(output, event), do: matches_sample?(output, event, "")

  def matches_sample?(output, event, prefix) do
    Regex.match?(~r/^sample##{prefix}#{event}=[0-9]+/u, output)
  end

  # All the machinations needed to start an app with a known config
  def with_initial_context(new_context, fun) do
    before_context = Application.get_env(:metrix, :context)

    silence(fn ->
      Application.stop(:metrix)
      Application.put_env(:metrix, :context, new_context)
      Application.start(:metrix)
    end)

    fun.(new_context)

    silence(fn ->
      Application.stop(:metrix)
      Application.put_env(:metrix, :context, before_context)
      Application.start(:metrix)
    end)
  end
end
