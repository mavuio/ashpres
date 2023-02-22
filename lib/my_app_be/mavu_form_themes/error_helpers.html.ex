defmodule MyAppBe.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """

  # def error_tag(form, field) do
  #   Enum.map(Keyword.get_values(form.errors, field), fn error ->
  #     content_tag(:span, translate_error(error), class: "invalid-feedback")
  #   end)
  # end

  def error_tag(form, field) do
    form.errors
    |> Keyword.get_values(field)
    |> Enum.map(fn error ->
      content_tag(:p, "↑ " <> translate_error(error),
        class: "mt-2 text-sm text-red-600",
        data: [phx_error_for: input_id(form, field)]
      )
    end)
  end

  def has_error(form, field) do
    form.errors
    |> Keyword.get_values(field)
    |> case do
      [] -> false
      _ -> true
    end
  end

  def standalone_error_tag(form, field) do
    form.errors
    |> Keyword.get_values(field)
    |> Enum.map(fn error ->
      content_tag(:div, translate_error(error),
        class: "alert alert-danger",
        data: [phx_error_for: input_id(form, field)]
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    # if count = opts[:count] do
    #   Gettext.dngettext(MyAppWeb.Gettext, "errors", msg, msg, count, opts)
    # else
    #   Gettext.dgettext(MyAppWeb.Gettext, "errors", msg, opts)
    # end
    msg
  end
end
