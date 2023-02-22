defmodule MyAppBe.BirdLive.BirdListComponent do
  @moduledoc false
  use MyAppBe, :live_component

  alias MyApp.Api
  alias MyApp.Bird
  require Ash.Query

  @impl true

  def update(%{id: _id, context: _context} = assigns, socket) do
    items_query =
      Bird
      |> Ash.Query.for_read(:mavu_list)
      |> Ash.Query.load([:tags])

    # first load
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       items_query: items_query,
       selected_ids: []
     )
     |> load_items()}
  end

  def load_items(socket) do
    socket
    |> assign(
      items_filtered:
        MavuList.process_list(
          socket.assigns.items_query,
          socket.assigns.id,
          listconf(),
          socket.assigns[:items_filtered][:tweaks] ||
            socket.assigns.context.params[MavuList.get_url_param_name(:items_filtered)] ||
            default_tweaks(socket.assigns.context)
        )
    )
  end

  def listconf() do
    %{
      columns: [
        %{name: :id, label: "ID"},
        %{name: :nickname, label: Ash.Resource.Info.field(Bird, :nickname).description},
        %{name: :type, label: Ash.Resource.Info.field(Bird, :type).description},
        %{name: :active, label: Ash.Resource.Info.field(Bird, :active).description},
        %{name: :weight, label: Ash.Resource.Info.field(Bird, :weight).description},
        %{name: :tags, label: "tags"}
      ],
      api: Api,
      filter: &listfilter/3
    }
  end

  def default_tweaks(_context) do
    %{sort_by: [[:nickname, :asc]]}
  end

  def listfilter(source, _conf, tweaks) do
    keyword = tweaks[:keyword]

    source =
      if MavuUtils.present?(keyword) do
        if MavuUtils.to_int(keyword) do
          id = MavuUtils.to_int(keyword)

          source
          |> Ash.Query.filter(id == ^id)
        else
          kwlike = "%#{keyword}%"

          source
          |> Ash.Query.filter(fragment("? ilike ?", nickname, ^kwlike))
        end
      else
        source
      end

    if MavuUtils.present?(tweaks[:filters]) do
      filters =
        tweaks[:filters]
        |> Map.to_list()
        |> Enum.map(fn
          {key, items} when is_list(items) -> {key, [slug: [in: items]]}
          x -> x
        end)
        |> Map.new()

      source |> Ash.Query.do_filter(filters)
    else
      source
    end
  end

  @impl true
  def handle_event("list." <> event, msg, socket) do
    {:noreply,
     socket
     |> MavuList.handle_event(
       event,
       msg,
       socket.assigns.items_query,
       :items_filtered
     )}
  end

  def rand_part() do
    Ecto.UUID.generate() |> String.split("-") |> hd()
  end

  # --- selection stuff start

  def handle_event(
        "update_selected_items",
        %{"action" => action_str} = _msg,
        socket
      )
      when action_str in ~w(activate deactivate delete) do
    for item_id <- socket.assigns.selected_ids do
      case action_str do
        "activate" ->
          Api.get!(Bird, item_id)
          |> Ash.Changeset.for_update(:update, %{active: true})
          |> Api.update!()

        "deactivate" ->
          Api.get!(Bird, item_id)
          |> Ash.Changeset.for_update(:update, %{active: false})
          |> Api.update!()

        "delete" ->
          Api.get!(Bird, item_id)
          |> Api.destroy!()
      end
    end

    {
      :noreply,
      socket
      |> assign(selected_ids: [])
      |> load_items()
    }
  end

  def handle_event("toggle_row_selection", %{"add-id" => id_str}, socket) do
    {:noreply,
     socket
     |> Phoenix.Component.update(:selected_ids, fn items -> items ++ [id_str] end)}
  end

  def handle_event("toggle_row_selection", %{"remove-id" => id_str}, socket) do
    {:noreply,
     socket
     |> Phoenix.Component.update(:selected_ids, fn items -> List.delete(items, id_str) end)}
  end

  def handle_event("toggle_row_selection", %{"toggle" => "none"}, socket) do
    {:noreply,
     socket
     |> assign(:selected_ids, [])}
  end

  def handle_event("toggle_row_selection", %{"toggle" => "all"}, socket) do
    {:noreply,
     socket
     |> assign(:selected_ids, socket.assigns.items_filtered.data |> Enum.map(&"#{&1.id}"))}
  end

  def handle_event(
        "set_tags_for_items",
        %{"type" => type_str, "tag-ids" => tag_ids_str} = _msg,
        socket
      )
      when type_str in ~w(add remove) do
    tag_ids = String.split(tag_ids_str)
    entity_ids = socket.assigns.selected_ids

    MyApp.Ashtags.handle_tags_on_entities(
      type_str,
      entity_ids,
      tag_ids,
      Api,
      MyApp.Bird
    )

    {
      :noreply,
      socket
      |> load_items()
    }
  end

  # --- selection stuff end
  @impl true
  def handle_event("duplicate", %{"id" => row_id}, socket) do
    record = Api.get!(Bird, row_id)

    Ash.Changeset.for_create(
      Bird,
      :create,
      Map.from_struct(record) |> Map.put(:nickname, record.nickname <> "_" <> rand_part())
    )
    |> Api.create()
    |> case do
      {:ok, new_rec} ->
        {:noreply,
         socket
         |> push_patch(
           to:
             MavuUtils.update_params_in_path(socket.assigns.context.current_url, rec: new_rec.id)
         )}

      {:error, err} ->
        err |> MavuUtils.log("mwuits-debug 2023-02-22_18:00 err clred", :info)
        {:noreply, socket}
    end
  end
end
