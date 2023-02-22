defmodule MyAppBe.BeAccounts.BeUserConfirmationInstructionsLive do
  use MyAppWeb, :live_view

  alias MyApp.BeAccounts

  def render(assigns) do
    ~H"""
    <.header>Resend confirmation instructions</.header>

    <.simple_form :let={f} for={:be_user} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={{f, :email}} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Sending...">Resend confirmation instructions</.button>
      </:actions>
    </.simple_form>

    <p class="my-4">
      <.link href={~p"/be/be_users/register"}>Register</.link>
      |
      <.link href={~p"/be/be_users/log_in"}>Log in</.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_instructions", %{"be_user" => %{"email" => email}}, socket) do
    if be_user = BeAccounts.get_be_user_by_email(email) do
      BeAccounts.deliver_be_user_confirmation_instructions(
        be_user,
        &url(~p"/be/be_users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
