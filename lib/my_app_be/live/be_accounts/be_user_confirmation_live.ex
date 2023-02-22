defmodule MyAppBe.BeAccounts.BeUserConfirmationLive do
  use MyAppWeb, :live_view

  alias MyApp.BeAccounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <.header>Confirm Account</.header>

    <.simple_form :let={f} for={:be_user} id="confirmation_form" phx-submit="confirm_account">
      <.input field={{f, :token}} type="hidden" value={@token} />
      <:actions>
        <.button phx-disable-with="Confirming...">Confirm my account</.button>
      </:actions>
    </.simple_form>

    <p class="my-4">
      <.link href={~p"/be/be_users/register"}>Register</.link>
      |
      <.link href={~p"/be/be_users/log_in"}>Log in</.link>
    </p>
    """
  end

  def mount(params, _session, socket) do
    {:ok, assign(socket, token: params["token"]), temporary_assigns: [token: nil]}
  end

  # Do not log in the be_user after confirmation to avoid a
  # leaked token giving the be_user access to the account.
  def handle_event("confirm_account", %{"be_user" => %{"token" => token}}, socket) do
    case BeAccounts.confirm_be_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "BeUser confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current be_user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the be_user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_be_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "BeUser confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
