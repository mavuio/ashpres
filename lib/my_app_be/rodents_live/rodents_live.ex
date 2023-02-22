defmodule MyAppBe.RodentsLive do
  @moduledoc false

  use MyAppBe, :live_view

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _, %{"rec" => rec} = _params) do
    socket
    |> assign(:page_title, "edit Rodent #{rec}")
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:page_title, "Rodents")
  end
end
