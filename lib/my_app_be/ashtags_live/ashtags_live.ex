defmodule MyAppBe.AshtagsLive do
  @moduledoc false

  use MyAppBe, :live_view

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign(context: MyAppBe.GenericLiveFunctions.create_context_from_params(params, session))
    }
  end

  @impl true
  def handle_params(params, url, socket) do
    socket = update_params_in_context(socket, params, url)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _, %{"rec" => rec} = _params) do
    socket
    |> assign(:page_title, "edit Tag #{rec}")
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:page_title, "Tags")
  end

  def update_params_in_context(%{assigns: %{context: context}} = socket, new_params, new_url)
      when is_map(context) do
    socket
    |> assign(
      context: %{
        context
        | params: new_params,
          current_url: new_url
      }
    )
  end

  def update_params_in_context(socket, _, _), do: socket
end
