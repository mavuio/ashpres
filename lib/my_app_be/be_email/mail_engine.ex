defmodule MyAppBe.BeEmail.MailEngine do
  @moduledoc false

  require Ecto.Query
  alias MyAppBe.BeEmail.MailVariants

  alias MyApp.Mailer

  def send_generic_text_mail(
        %{text: text, subject: subject} = _mail_content,
        recipient,
        _opts \\ []
      )
      when is_binary(text) and is_binary(recipient) do
    email = MailVariants.generic_text_mail(%{text: text, subject: subject}, recipient)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
