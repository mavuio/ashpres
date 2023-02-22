defmodule MyAppBe.BeUserUi.BeUserLive do
  @moduledoc false

  use MyAppBe, :live_view

  @impl true
  def mount(_params, _session, socket) do
    context =
      Map.merge(socket.assigns.context, %{
        be_user_ui_conf: MavuBeUserUi.default_conf(%{})
      })

    {:ok,
     socket
     |> assign(context: context)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _, %{"rec" => rec} = _params) do
    socket
    |> assign(:page_title, "edit User #{rec}")
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:page_title, "User List")
  end
end
