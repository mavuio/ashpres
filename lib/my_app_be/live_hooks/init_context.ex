defmodule MyAppBe.LiveHooks.InitContext do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(_, params, session, socket) do
    context = %{
      params: params,
      lang: params["lang"] || "de",
      current_url: nil,
      session: session,
      url_options: MyAppWeb.MyHelpers.get_url_options_from_params(params)
    }

    {socket, session} |> MavuUtils.log("mwuits-debug 2023-02-06_12:52  clred initcontext", :info)

    {:cont,
     socket
     |> assign(:context, context)
     |> attach_hook(:update_context, :handle_params, &update_params_in_context/3)}
  end

  defp update_params_in_context(new_params, new_url, %{assigns: %{context: context}} = socket)
       when is_map(context) do
    {:cont,
     socket
     |> assign(
       context:
         Map.merge(context, %{
           params: new_params,
           current_url: extract_path_from_url(new_url)
         })
     )}
  end

  defp update_params_in_context(_, _, socket), do: {:cont, socket}

  defp extract_path_from_url(url) when is_binary(url) do
    url = url |> URI.parse() |> Map.take(~w(path query)a)

    struct(URI, url)
    |> URI.to_string()
    |> String.replace_suffix("/", "")
  end

  defp extract_path_from_url(_), do: ""
end
