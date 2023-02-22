defmodule MyAppBe.BeAccounts.BeUserRegistrationLive do
  use MyAppWeb, :live_view

  alias MyApp.BeAccounts
  alias MyApp.BeAccounts.BeUser

  def render(assigns) do
    ~H"""
    <div class="max-w-sm mx-auto">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/be/be_users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="registration_form"
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/be/be_users/log_in?_action=registered"}
        method="post"
        as={:be_user}
      >
        <.error :if={@changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={{f, :email}} type="email" label="Email" required />
        <.input field={{f, :password}} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = BeAccounts.change_be_user_registration(%BeUser{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"be_user" => be_user_params}, socket) do
    case BeAccounts.register_be_user(be_user_params) do
      {:ok, be_user} ->
        # {:ok, _} =
        #   BeAccounts.deliver_be_user_confirmation_instructions(
        #     be_user,
        #     &url(~p"/be/be_users/confirm/#{&1}")
        #   )

        # if this user is the first one in the database:
        be_user =
          if BeAccounts.get_number_of_be_users() == 1 do
            BeAccounts.activate_user(be_user, true)
          else
            be_user
          end

        changeset = BeAccounts.change_be_user_registration(be_user)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"be_user" => be_user_params}, socket) do
    changeset = BeAccounts.change_be_user_registration(%BeUser{}, be_user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
