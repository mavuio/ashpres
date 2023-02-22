defmodule MyAppBe.AshtagLive.AshtagEditComponent do
  @moduledoc false
  use MyAppBe, :live_component

  alias MyApp.Api
  alias MyApp.Ashtags.Tag

  @impl true

  def update(%{rec_id: "new"} = assigns, socket) do
    form =
      Tag
      |> AshPhoenix.Form.for_create(:create,
        api: Api
      )

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(item: %{}, form: form)
    }
  end

  def update(%{rec_id: _rec_id} = assigns, socket) do
    item = load_item(assigns)

    form =
      item
      |> AshPhoenix.Form.for_update(:update,
        api: Api
      )

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(item: item, form: form)
    }
  end

  def load_item(assigns) do
    Tag
    |> Api.get(assigns.rec_id)
    |> case do
      {:ok, item} -> item
      _ -> nil
    end
  end

  @impl true

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: true)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", _params, socket) do
    socket =
      case AshPhoenix.Form.submit(socket.assigns.form) do
        {:ok, result} ->
          result |> MavuUtils.log("mwuits-debug 2022-11-09_22:37  SAVE clgreen", :info)

          socket
          |> assign(item: load_item(socket.assigns))
          |> push_patch(
            to: MavuUtils.update_params_in_path(socket.assigns.context.current_url, rec: nil)
          )

        {:error, form} ->
          form.submit_errors |> MavuUtils.log("mwuits-debug 2022-11-09_22:37  ERROR clred", :info)

          socket |> assign(form: form)
      end

    {:noreply, socket}
  end
end
