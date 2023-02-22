defmodule MyAppBe.BeEmail.MailVariants do
  # use Bamboo.Phoenix, view: MyAppBe.BeEmailView

  import MavuUtils, warn: false

  import Phoenix.HTML.Format

  use Phoenix.Swoosh,
    template_root: "lib/my_app_be/be_email",
    template_path: "mail_templates",
    layout: {MyAppBe.BeEmail.MailVariants, :default_mail_layout}

  defp base_email do
    new()
    |> from(default_sender())
  end

  def generic_text_mail(
        %{text: text, subject: subject} = mail_content,
        recipient,
        _opts \\ []
      )
      when is_binary(text) and is_binary(subject) do
    base_email()
    |> to(recipient)
    |> subject(subject)
    |> render_body(:generic_text_mail, mail_content)
  end

  def default_sender() do
    {"server", "server@mavu.io"}
  end
end
