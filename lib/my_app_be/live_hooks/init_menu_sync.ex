defmodule MyAppBe.LiveHooks.InitMenuSync do
  @moduledoc """
  Syncs url-changes with navigation menu by sending a javascripet-event to the client.

  important: depends on  "context.current_url" url being set before
  """
  import Phoenix.LiveView
  # import Phoenix.Component

  def on_mount(_, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:menu_sync, :handle_params, &sync_menu/3)}
  end

  defp sync_menu(
         _new_params,
         _new_url,
         %{assigns: %{context: %{current_url: current_url}}} = socket
       ) do
    {:cont, socket |> push_event("url_changed", %{url: current_url})}
  end

  defp sync_menu(_new_params, _new_url, socket), do: {:cont, socket}
end
