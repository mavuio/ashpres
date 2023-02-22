defmodule MyAppBe.AshtagChooserComponent do
  @moduledoc false
  alias MyApp.Ashtags.Tag
  alias MyApp.Ashtags
  alias MyApp.Api
  use MyAppBe, :live_component

  @impl true
  def update(assigns, socket) do
    input_id = "local_input_#{assigns.id}"

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_new(:class, fn _ -> "" end)
      |> assign(
        input_id: input_id,
        kw: "",
        found_tags: [],
        chosen_tags: prepopulate_tags(assigns[:tags])
      )
      # |> assign(editmode: false)
      # |> assign(data: ProdC.get_analyze_data(assigns.prod))
    }
  end

  def prepopulate_tags(tag_ids_or_slugs) when is_list(tag_ids_or_slugs) do
    tag_ids_or_slugs
    |> Enum.map(&Ashtags.get_tag_by_uuid_or_slug/1)
    |> Enum.filter(fn x -> not is_nil(x) end)
    |> MavuUtils.log("mwuits-debug 2022-11-08_16:38 PREPOP", :info)
  end

  def prepopulate_tags(_), do: []

  @impl true

  def handle_event("change_kw", kw, socket) do
    {:noreply,
     socket
     |> assign(kw: kw, found_tags: get_tags_for_keyword(kw))}
  end

  def handle_event("add_tag", %{"id" => tag_id}, socket) do
    {:noreply,
     socket
     |> assign(chosen_tags: add_tag(socket.assigns.chosen_tags, tag_id))
     |> assign(kw: "", found_tags: [])
     |> trigger_change_event()}
  end

  def handle_event("remove_tag", %{"id" => tag_id}, socket) do
    {:noreply,
     socket
     |> assign(chosen_tags: remove_tag(socket.assigns.chosen_tags, tag_id))
     |> assign(found_tags: [])
     |> trigger_change_event()}
  end

  def trigger_change_event(%{assigns: %{on_change: on_change_fun}} = socket)
      when is_function(on_change_fun, 2) do
    on_change_fun.(socket, socket.assigns.chosen_tags)
  end

  def trigger_change_event(socket), do: socket

  def add_tag(current_tags, new_tag_id) when is_list(current_tags) do
    Api.get(Tag, new_tag_id)
    |> case do
      {:ok, new_tag} ->
        (current_tags ++ [new_tag]) |> Enum.uniq()

      _ ->
        current_tags
    end
  end

  def remove_tag(current_tags, remove_tag_id) when is_list(current_tags) do
    current_tags
    |> Enum.filter(&(&1.id != remove_tag_id))
  end

  def get_tags_for_keyword(nil), do: []

  def get_tags_for_keyword(""), do: []

  def get_tags_for_keyword(kw) do
    Tag.get_tags_for_keyword!(kw)
  end
end
