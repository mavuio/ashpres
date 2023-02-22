defmodule MyAppWeb.MyHelpers do
  def local_date(utc_date) do
    DateTime.from_naive(utc_date, "Etc/UTC")
    |> case do
      {:ok, date} ->
        DateTime.shift_zone(date, "Europe/Vienna")
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

  def datetime_string() do
    DateTime.utc_now() |> local_date() |> NaiveDateTime.truncate(:second) |> to_string()
  end

  def format_date(utc_date) do
    utc_date
    |> local_date()
  end

  def trans(lang_or_params, txt_l1, txt_l2 \\ nil) do
    case lang_from_params(lang_or_params) do
      "en" -> if MavuUtils.present?(txt_l2), do: txt_l2, else: txt_l1
      _ -> txt_l1
    end
  end

  def lang_from_params(lang_or_params) do
    case lang_or_params do
      map when is_map(lang_or_params) -> map["lang"] || map[:lang] || "en"
      str when is_binary(str) -> str
      _ -> "en"
    end
  end

  def get_url_options_from_params(params) do
    params
    |> Map.take(~w(no_cache clear_cache))
    |> AtomicMap.convert(safe: true)
    |> Map.to_list()
  end

  def state_from_changeset(cs) do
    f = Phoenix.HTML.Form.form_for(cs, "#", as: :dummy)

    f.data
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, acc ->
      Map.put(acc, key, Phoenix.HTML.Form.input_value(f, key))
    end)
  end

  def clean_state_from_changeset(cs) do
    cs
    |> Ecto.Changeset.apply_action(:update)
    |> case do
      {:ok, clean_data} -> clean_data
      _ -> nil
    end
  end
end
