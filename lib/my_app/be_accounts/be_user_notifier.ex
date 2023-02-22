defmodule MyApp.BeAccounts.BeUserNotifier do
  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #

  alias MyAppBe.BeEmail.MailEngine

  defp deliver(to, body, subject \\ "no subject") do
    require Logger

    Logger.debug(body)

    MailEngine.send_generic_text_mail(%{text: body, subject: subject}, to)

    {:ok, %{to: to, body: body}}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(be_user, url) do
    deliver(
      be_user.email,
      """

      ==============================

      Hi #{be_user.email},

      You can confirm your account by visiting the URL below:

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """,
      "you requested a password-reset"
    )
  end

  @doc """
  Deliver instructions to reset a be_user password.
  """
  def deliver_reset_password_instructions(be_user, url) do
    deliver(
      be_user.email,
      """

      ==============================

      Hi #{be_user.email},

      You can reset your password by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ==============================
      """,
      "reset password"
    )
  end

  @doc """
  Deliver instructions to update a be_user email.
  """
  def deliver_update_email_instructions(be_user, url) do
    deliver(be_user.email, """

    ==============================

    Hi #{be_user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
