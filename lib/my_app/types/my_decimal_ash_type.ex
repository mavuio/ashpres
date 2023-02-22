defmodule MyApp.Types.MyDecimalAshType do
  @constraints [
    max: [
      type: {:custom, __MODULE__, :decimal, []},
      doc: "Enforces a maximum on the value"
    ],
    min: [
      type: {:custom, __MODULE__, :decimal, []},
      doc: "Enforces a minimum on the value"
    ]
  ]
  @moduledoc """
  Represents a decimal.

  based on defmodule Ash.Type.Decimal, but using MyApp.Decimal for parsing

  A builtin type that can be referenced via `:my_decimal`

  ### Constraints

  #{Spark.OptionsHelpers.docs(@constraints)}
  """
  use Ash.Type

  @impl true
  def generator(constraints) do
    StreamData.float(Keyword.take(constraints, [:min, :max]))
    |> StreamData.map(&Decimal.from_float/1)
  end

  @impl true
  def storage_type, do: :decimal

  @impl true
  def constraints, do: @constraints

  @doc false
  def decimal(value) do
    case cast_input(value, []) do
      {:ok, decimal} ->
        {:ok, decimal}

      :error ->
        {:error, "cannot be casted to decimal"}
    end
  end

  @impl true
  def apply_constraints(nil, _), do: :ok

  def apply_constraints(value, constraints) do
    errors =
      Enum.reduce(constraints, [], fn
        {:max, max}, errors ->
          if Decimal.compare(value, max) == :gt do
            [[message: "must be less than or equal to %{max}", max: max] | errors]
          else
            errors
          end

        {:min, min}, errors ->
          if Decimal.compare(value, min) == :lt do
            [[message: "must be more than or equal to %{min}", min: min] | errors]
          else
            errors
          end
      end)

    case errors do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  # from Ash.Type.Decimal:
  # @impl true
  # def cast_input(value, _) when is_binary(value) do
  #   case Decimal.parse(value) do
  #     {decimal, ""} ->
  #       {:ok, decimal}
  #     _ ->
  #       :error
  #   end
  # end
  # @impl true
  # def cast_input(value, _) do
  #   Ecto.Type.cast(:decimal, value)
  # end

  @impl true
  def cast_input(val, _) do
    res = MyApp.Decimals.to_dec(val)

    cond do
      MyApp.Decimals.is_dec(res) -> {:ok, res}
      is_nil(res) -> {:ok, nil}
      true -> :error
    end
  end

  # from MyApp.Types.MyDecimalType
  # def cast(val) do
  #   res = to_dec(val)

  #   cond do
  #     is_dec(res) -> {:ok, res}
  #     is_nil(res) -> {:ok, nil}
  #     true -> :error
  #   end
  # end

  def cast_stored(value, _) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} ->
        {:ok, decimal}

      _ ->
        :error
    end
  end

  @impl true
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, _) do
    Ecto.Type.load(:decimal, value)
  end

  @impl true
  @spec dump_to_native(any, any) :: :error | {:ok, any}
  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(value, _) do
    Ecto.Type.dump(:decimal, value)
  end

  @doc false
  def new(%Decimal{} = v), do: v
  def new(v), do: Decimal.new(v)
end
