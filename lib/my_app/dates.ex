defmodule MyApp.Dates do
  @moduledoc false

  # sample usage:
  # import MyApp.Dates
  # def times_for_day(%Date{} = day) do
  # end

  # def times_for_day(day) when is_maybe_date(day), do: times_for_day(to_date(day))
  # def times_for_day(_), do: []

  import MavuUtils

  defguard is_maybe_date(term)
           when is_binary(term) or is_nil(term) or is_integer(term) or is_struct(term, Date) or
                  term in [:today, :tomorrow, :yesterday]

  defguard is_date(term)
           when is_struct(term, Date)

  def is_parsable_date?(date) do
    case to_date(date) do
      d when is_date(d) -> true
      _ -> false
    end
  end

  def to_date(%Date{} = date) do
    date
  end

  def to_date(:today) do
    to_date(0)
  end

  def to_date(:tomorrow) do
    to_date(1)
  end

  def to_date(:yesterday) do
    to_date(-1)
  end

  def to_date(days) when is_integer(days) do
    Elixir.DateTime.utc_now()
    |> MyAppWeb.MyHelpers.local_date()
    |> Date.add(days)
    |> to_date()
  end

  def to_date(nil) do
    :error_no_date
  end

  def to_date({y, m, d}) do
    Date.new(y |> to_int(), m |> to_int(), d |> to_int())
    |> case do
      {:ok, date} -> date
      _ -> nil
    end
    |> to_date()
  end

  def to_date(str) when is_binary(str) do
    nil
    |> case do
      nil ->
        Regex.named_captures(~r/(?<d>\d\d?)\.(?<m>\d\d?)\.(?<y>\d\d\d\d)/, str)
        # p->p
    end
    |> case do
      nil -> Regex.named_captures(~r/(?<y>\d\d\d\d?)[-_](?<m>\d\d?)[-_](?<d>\d\d)/, str)
      p -> p
    end
    |> case do
      %{"d" => d, "m" => m, "y" => y} -> {y, m, d}
      _ -> nil
    end
    |> to_date()
  end

  def format_day(date) do
    :io_lib.format("~2..0B.~2..0B.~4..0B", [date.day, date.month, date.year])
    |> IO.iodata_to_binary()
  end

  def format_date(date, format \\ "%y-%m-%d") when is_date(date) do
    Calendar.strftime(date, format)
  end

  def format_daterange(d1, d2) when is_date(d1) and is_date(d2) do
    cond do
      d1.year == d2.year && d1.month == d2.month ->
        format_date(d1, "%d.") <> " - " <> format_date(d2, "%d. %b %Y")

      d1.year == d2.year ->
        format_date(d1, "%d. %b") <> " - " <> format_date(d2, "%d. %b %Y")

      true ->
        format_date(d1, "%d. %b %Y") <> " - " <> format_date(d2, "%d. %b %Y")
    end
  end

  def date_to_iso_str(date) do
    :io_lib.format("~4..0B-~2..0B-~2..0B", [date.year, date.month, date.day])
    |> IO.iodata_to_binary()
  end

  def date_to_month_str(date) do
    :io_lib.format("~4..0B-~2..0B", [date.year, date.month])
    |> IO.iodata_to_binary()
  end
end
