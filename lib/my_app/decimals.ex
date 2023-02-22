defmodule MyApp.Decimals do
  @moduledoc false

  import MavuUtils
  require Decimal
  def to_dec(""), do: nil
  def to_dec(nil), do: nil
  def to_dec(i) when is_integer(i), do: Decimal.new(i)
  def to_dec(%Decimal{} = v), do: v

  def to_dec(original_str) do
    case Decimal.parse(original_str |> fuzzy_handle_german_strings()) do
      :error -> original_str
      {%Decimal{} = dec, ""} -> dec
      {_dec, rest} when is_binary(rest) -> original_str
    end
  end

  def fuzzy_handle_german_strings(str) when is_binary(str) do
    str2 =
      if String.contains?(str, ",") do
        # remove grouping chars, if present
        str |> String.replace(".", "")
      else
        str
      end

    str2
    |> String.replace(",", ".")
    |> case do
      "." -> "0"
      str -> str
    end
  end

  def fuzzy_handle_german_strings(val), do: fuzzy_handle_german_strings(to_string(val))

  def is_dec(val), do: Decimal.is_decimal(val)

  def is_parsable_to_dec?(str) do
    is_dec(to_dec(str))
  end

  # default num of digits after comma:
  @num_digits 3

  def simplify_decimal(decimal, num_digits \\ @num_digits)

  def simplify_decimal(%Decimal{} = decimal, _num_digits) do
    simplify_decimal(Decimal.to_string(decimal, :normal))
    |> to_dec()
  end

  def simplify_decimal(val, num_digits) when is_binary(val) do
    Regex.run(~r/^(\d+)(\.(\d+))?$/, val)
    |> case do
      [_, pre, _, post] ->
        post =
          Float.parse("0." <> post)
          |> elem(0)
          |> Float.round(num_digits)
          |> Float.to_string()
          |> String.slice(2, 10)

        case post do
          "" -> to_int(pre)
          "0" -> to_int(pre)
          _ -> Float.parse("#{pre}.#{post}") |> elem(0)
        end

      # "#{pre}.#{post}"
      [_, int] ->
        to_int(int)

      _ ->
        val
    end
  end

  def simplify_decimal(val, _num_digits), do: val

  def simplify_decimals_in_map(map) when is_map(map) do
    map
    |> Map.to_list()
    |> Enum.map(fn {key, val} -> {key, simplify_decimal(val)} end)
    |> Map.new()
  end

  def add(a, b) do
    Decimal.add(to_dec(a) || "0", to_dec(b) || "0")
  end

  def sub(a, b) do
    Decimal.sub(to_dec(a) || "0", to_dec(b) || "0")
  end

  def mult(a, b) do
    Decimal.mult(to_dec(a) || "0", to_dec(b) || "0")
  end
end
