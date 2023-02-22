defmodule MyAppBe.MavuList.TagfilterComponent do
  @moduledoc false
  use MyAppBe, :live_component

  @impl true
  def update(%{list: list, fieldname: fieldname} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)

      # |> assign_new(:class, fn _ -> "" end)
      # |> assign(label: assigns[:label] || "filter by '#{fieldname}'")
      |> assign(generate_assigns_for_tagfilter_component(list, fieldname))

    {:ok, socket}
  end

  def on_tag_change(socket, tags) when is_list(tags) do
    socket
    |> Phoenix.LiveView.push_event("ashtags_changed", %{
      tag_slugs: tags |> Enum.map(& &1.slug) |> Enum.join(",")
    })
  end

  def generate_assigns_for_tagfilter_component(%MavuList{} = state, fieldname)
      when is_atom(fieldname) do
    %{
      target: MavuList.get_target(state),
      value: state.tweaks[:filters][fieldname]
    }
  end
end
