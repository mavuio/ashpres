defmodule MyAppBe.MavuList.SearchboxComponent do
  @moduledoc false
  use MyAppBe, :live_component

  @impl true
  def update(%{list: list} = _assigns, socket) do
    socket =
      socket
      |> assign(MavuList.generate_assigns_for_searchbox_component(list))

    {:ok, socket}
  end
end
