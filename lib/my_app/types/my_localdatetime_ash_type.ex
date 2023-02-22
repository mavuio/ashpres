defmodule MyApp.Types.MyLocaldatetimeAshType do
  @moduledoc """
  Represents a utc datetime in database, displayed as local-time in application
  (auto-converted)

  A builtin type that can be referenced via `:my_localdatetime`

  use in ressource DSL like this:
      create_timestamp :inserted_at, type: :my_localdatetime

      attribute :occured_at, :my_localdatetime
      and,put this in the generated migration file, to keep defaults at utc in postgres
      (only needed for attribute not for create_timestamp)

      default: fragment("timezone('utc', now())")

  """
  use Ash.Type

  @my_app_timezone Application.compile_env(:my_app, :timezone)

  @impl true
  def storage_type, do: :utc_datetime

  @impl true
  def generator(_constraints) do
    # Waiting on blessed date/datetime generators in stream data
    # https://github.com/whatyouhide/stream_data/pull/161/files
    StreamData.constant(DateTime.utc_now())
  end

  @impl true
  def cast_input(value, _) do
    Ecto.Type.cast(:naive_datetime, value)
  end

  @impl true
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, constraints) when is_binary(value) do
    cast_input(value, constraints)
  end

  def cast_stored(value, _) do
    Ecto.Type.load(:utc_datetime, value)
    |> case do
      {:ok, date} -> {:ok, date |> utc_to_local_date()}
      b -> b
    end
  end

  @impl true

  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(value, _) do
    Ecto.Type.dump(:naive_datetime, value)
    |> case do
      {:ok, date} -> {:ok, date |> local_to_utc_date()}
      b -> b
    end
  end

  def local_now do
    DateTime.utc_now() |> utc_to_local_date()
  end

  def utc_to_local_date(utc_date) do
    DateTime.from_naive(utc_date, "Etc/UTC")
    |> case do
      {:ok, date} ->
        DateTime.shift_zone(date, @my_app_timezone)
        |> case do
          {:ok, date} ->
            DateTime.to_naive(date)

          _ ->
            utc_date
        end

      _ ->
        utc_date
    end
  end

  def local_to_utc_date(local_date) do
    DateTime.from_naive(local_date, @my_app_timezone)
    |> case do
      {:ok, date} ->
        DateTime.shift_zone(date, "Etc/UTC")
        |> case do
          {:ok, date} ->
            DateTime.to_naive(date)

          _ ->
            local_date
        end

      _ ->
        local_date
    end
  end
end
