defmodule MyAppBe.AshtagLive.AshtagListComponent do
  @moduledoc false
  use MyAppBe, :live_component

  alias MyApp.Api
  alias MyApp.Ashtags.Tag
  require Ash.Query

  @impl true

  def update(%{id: _id, context: _context} = assigns, socket) do
    items_query =
      Tag
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
        %{name: :id, label: "ID", hidden: "yes"},
        %{name: :slug, label: "tag"}
      ],
      api: Api,
      filter: &listfilter/3
    }
  end

  def default_tweaks(_context) do
    %{sort_by: [[:slug, :asc]]}
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
          Api.get!(Tag, item_id)
          |> Ash.Changeset.for_update(:update, %{active: true})
          |> Api.update!()
          socket

        "deactivate" ->
          Api.get!(Tag, item_id)
          |> Ash.Changeset.for_update(:update, %{active: false})
          |> Api.update!()
          socket

        "delete" ->

          tag=Api.get!(Tag, item_id)
          try do
            tag |> Api.destroy!()
          rescue
            e in Ecto.ConstraintError ->

              case e do
                %{ constraint: "product_to_tag_tag_id_fkey"}->
                  {:error, "cannot delete tag '#{tag[:slug]}', it is still used on some products"}
                  _ -> nil
              end

          end
      end
    end
    |> push_errors_if_any()

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

def push_errors_if_any(results) when is_list(results) do

results  |> Enum.map(fn
    {:error,msg} -> msg
    _->nil end)
    |> Enum.filter(&( not is_nil(&1) ))
    |> case do
    [_|_]=errors->
      push_flash(:error, errors   |> Enum.map(&( "➜ #{&1}" ))|> Enum.join("<br/>&nbsp;<br/>")  |> raw())
      _->nil
  end



  end
  # --- selection stuff end


end
