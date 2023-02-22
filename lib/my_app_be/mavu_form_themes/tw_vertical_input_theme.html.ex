defmodule MyAppBe.TwVerticalInputTheme do
  use Phoenix.HTML
  # now only used y tailwind to pick up classes

  @doc """
  set default options
  """
  def default_options(_form, _field, _opts) do
    [
      raw_label: [update_html: &mark_label_as_required/1]
    ]
  end

  def wrap(html, block_name, assigns) when is_atom(block_name) do
    my_classes = get_classes_for_element(block_name, assigns)

    tag_options =
      MavuForm.get_tag_options_for_block(block_name, assigns)
      |> Keyword.put(:class, MavuForm.process_classes(my_classes, block_name, assigns))

    tagname =
      case block_name do
        :wrapped_label -> :label
        _ -> :div
      end

    content_tag(tagname, MavuForm.process_html(html, block_name, assigns), tag_options)
  end

  def get_classes_for_element(block_name, assigns) when is_atom(block_name) and is_map(assigns) do
    case block_name do
      :container ->
        "my-4"

      :label_block ->
        ""

      :input_block ->
        "sm:flex-auto"

      :wrapped_label ->
        case {assigns.type, assigns.has_error} do
          {:checkbox, true} -> "pl-2 text-sm font-normal text-red-600"
          {:checkbox, false} -> "pl-2 text-sm font-normal text-gray-600"
          {_, _} -> "block text-sm font-medium text-gray-600"
        end

      :wrapped_input ->
        case {assigns.type, assigns.has_error} do
          {:checkbox, _} -> "relative flex "
          {_, _} -> "relative m-1"
        end

      :raw_label ->
        nil

      :raw_input ->
        case {assigns.type, assigns.has_error} do
          {:checkbox, _} ->
            " ml-1 border-gray-300  shadow-sm focus:ring-primary-500 focus:border-primary-500  rounded text-primary-700 "

          {_, false} ->
            "block w-full border-gray-300 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 sm:text-sm placeholder-gray-300 "

          {_, true} ->
            "block w-full pr-10 text-red-900 placeholder-red-300 border-red-300 rounded-md focus:outline-none focus:ring-red-500 focus:border-red-500 sm:text-sm"
        end
    end
  end

  def error_block(assigns) do
    assigns.form.errors
    |> Keyword.get_values(assigns.field)
    |> Enum.map(fn error ->
      content_tag(:p, "↑ " <> MyAppBe.ErrorHelpers.translate_error(error),
        class: "mt-2 text-sm text-red-600",
        data: [phx_error_for: input_id(assigns.form, assigns.field)]
      )
    end)
  end

  def mark_label_as_required(assigns) do
    if assigns.opts[:required] do
      [assigns.inner_content, raw(~s(<sup class="ml-1">*</sup>))]
    else
      assigns.inner_content
    end
  end
end
