defmodule MyAppBe.BeAccounts.BeUserInitPasswordLive do
  use MyAppWeb, :live_view

  alias MyApp.BeAccounts

  def render(assigns) do
    ~H"""
    <.header>
      Set up your account
      <:subtitle>please choose a password for your account:</:subtitle>
    </.header>

    <.simple_form
      :let={f}
      for={@changeset}
      id="init_password_form"
      phx-submit="init_password"
      phx-change="validate"
    >
      <.error :if={@changeset.action == :insert}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={{f, :password}} type="password" label="New password" required />
      <.input
        field={{f, :password_confirmation}}
        type="password"
        label="Confirm new password"
        required
      />
      <:actions>
        <.button phx-disable-with="Initializing...">Init Password</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_be_user_and_token(socket, params)

    socket =
      case socket.assigns do
        %{be_user: be_user} ->
          assign(socket, :changeset, BeAccounts.change_be_user_password(be_user))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  # Do not log in the be_user after reset password to avoid a
  # leaked token giving the be_user access to the account.
  def handle_event("init_password", %{"be_user" => be_user_params}, socket) do
    case BeAccounts.init_be_user_password(socket.assigns.be_user, be_user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password set successfully.")
         |> redirect(to: ~p"/be/be_users/log_in")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"be_user" => be_user_params}, socket) do
    changeset = BeAccounts.change_be_user_password(socket.assigns.be_user, be_user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  defp assign_be_user_and_token(socket, %{"token" => token}) do
    if be_user = BeAccounts.get_be_user_by_init_password_token(token) do
      assign(socket, be_user: be_user, token: token)
    else
      socket
      |> put_flash(:error, "Init password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end
end
