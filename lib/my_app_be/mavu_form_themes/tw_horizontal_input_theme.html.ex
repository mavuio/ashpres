defmodule MyAppBe.TwHorizontalInputTheme do
  use Phoenix.HTML

  def wrap(content, block_name, assigns) when is_atom(block_name) do
    my_classes = get_classes_for_element(block_name, assigns)

    tag_options =
      MavuForm.get_tag_options_for_block(block_name, assigns)
      |> Keyword.put(:class, my_classes |> MavuForm.process_classes(block_name, assigns))

    content_tag(:div, content, tag_options)
  end

  def get_classes_for_element(block_name, assigns) when is_atom(block_name) and is_map(assigns) do
    case block_name do
      :container ->
        "sm:flex my-4"

      :label_block ->
        "sm:flex-initial sm:w-1/3 sm: ml-1"

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
end
