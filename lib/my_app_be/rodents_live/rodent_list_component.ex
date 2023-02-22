defmodule MyAppBe.RodentLive.RodentListComponent do
  @moduledoc false
  use MyAppBe, :live_component

  alias MyApp.Api
  alias MyApp.Rodent
  require Ash.Query

  @impl true

  def update(%{id: _id, context: _context} = assigns, socket) do
    items_query =
      Rodent
      |> Ash.Query.for_read(:mavu_list)

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
        %{name: :name, label: "name"},
        %{name: :active, label: "active"},
        %{name: :type, label: "type"}
      ],
      api: Api,
      filter: &listfilter/3
    }
  end

  def default_tweaks(_context) do
    %{sort_by: [[:name, :asc]]}
  end

  def listfilter(source, _conf, tweaks) do
    keyword = tweaks[:keyword]

    if MavuUtils.present?(keyword) do
      if MavuUtils.to_int(keyword) do
        id = MavuUtils.to_int(keyword)

        source
        |> Ash.Query.filter(id == ^id)
      else
        kwlike = "%#{keyword}%"

        source
        |> Ash.Query.filter(fragment("? ilike ?", name, ^kwlike))
      end
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
          Api.get!(Rodent, item_id)
          |> Ash.Changeset.for_update(:update, %{active: true})
          |> Api.update!()

        "deactivate" ->
          Api.get!(Rodent, item_id)
          |> Ash.Changeset.for_update(:update, %{active: false})
          |> Api.update!()

        "delete" ->
          Api.get!(Rodent, item_id)
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

  # --- selection stuff end
end
