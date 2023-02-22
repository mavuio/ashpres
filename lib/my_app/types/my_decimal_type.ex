defmodule MyApp.Types.MyDecimalType do
  @behaviour Ecto.Type

  import MyApp.Decimals

  @doc """
  - type should output the name of the DB type
  - cast should receive any type and output your custom Ecto type (=list)
  - load should receive the DB type and output your custom Ecto type
  - dump should receive your custom Ecto type and output the DB type
  """
  def type, do: :decimal

  def cast(val) do
    res = to_dec(val)

    cond do
      is_dec(res) -> {:ok, res}
      is_nil(res) -> {:ok, nil}
      true -> :error
    end
  end

  def load(value), do: {:ok, value}
  def dump(value), do: {:ok, value}

  def embed_as(_), do: :self

  def equal?(a, b), do: a == b
end
