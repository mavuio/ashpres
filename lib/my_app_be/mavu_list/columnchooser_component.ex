defmodule MyAppBe.MavuList.ColumnchooserComponent do
  @moduledoc false
  use MyAppBe, :live_component

  alias Phoenix.LiveView.JS

  @impl true
  def update(%{list: list, id: id} = assigns, socket) do
    socket =
      socket
      |> assign(
        id: id,
        list: list,
        dd_id: assigns.id <> "_dd",
        button_id: assigns.id <> "_button",
        open: false
      )

    {:ok, socket}
  end

  def hide_dd(js \\ %JS{}, id) do
    js
    |> JS.hide(
      transition: {"ease-out duration-300", "opacity-0", "opacity-100"},
      to: "##{id}",
      time: 1000
    )
  end

  @impl true
  def handle_event("open_dd", _msg, socket) do
    {:noreply, socket |> assign(open: true)}
  end

  def handle_event("close_dd", _msg, socket) do
    socket = socket |> assign(open: false)
    {:noreply, socket}
  end
end
