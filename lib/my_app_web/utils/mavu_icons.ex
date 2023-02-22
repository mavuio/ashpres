defmodule MavuIcons do
  @moduledoc false

  import Phoenix.HTML, warn: false

  def loading(opts \\ []) do
    ~s"""
    <svg #{to_attrs(opts)} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
    <circle opacity="0.25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path opacity="0.75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
    """
  end

  def circle(opts \\ []) do
    ~s"""
    <svg #{to_attrs(opts)} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
    <circle  cx="12" cy="12" r="10" stroke="currentColor" stroke-width="#{opts[:stroke_width] || 4}"></circle>
    </svg>
    """
  end

  def to_attrs(opts), do: opts |> Enum.map_join(fn {k, v} -> ~s( #{k}="#{v}") end)
end
