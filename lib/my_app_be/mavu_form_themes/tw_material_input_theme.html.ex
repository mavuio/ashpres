defmodule MyAppBe.TwMaterialInputTheme do
  use Phoenix.HTML
  # now only used y tailwind to pick up classes

  alias MavuForm.InputHelpers
  # import MavuForm.MfHelpers
  import MavuUtils

  @doc """
  set default options
  """
  def default_options(form, field, opts) do
    defopts = [
      raw_label: [update_html: &mark_label_as_required(form, field, &1)],
      placeholder: " "
    ]

    if opts[:using] == :select do
      defopts
      |> Keyword.put(
        :"data-value",
        (Phoenix.HTML.Form.input_value(form, field) || opts[:selected]) |> to_string()
      )
      |> Keyword.delete(:placeholder)
      |> Keyword.put(
        :onblur,
        "this.setAttribute('data-value', this.value);"
      )
    else
      defopts
    end
  end

  def input(assigns) do
    # label_block = MavuForm.label_block(assigns)
    input_block = InputHelpers.input_block(assigns)

    "MATERIAL_INPUT" |> MavuUtils.log("mwuits-debug 2022-11-29_14:54 clyellow", :info)

    InputHelpers.theme_module(assigns).wrap(
      [
        # label_block,
        input_block
      ],
      :container,
      assigns
    )
  end

  def input_block(assigns) do
    wrapped_input = InputHelpers.wrapped_input(assigns)
    error_block = InputHelpers.error_block(assigns)
    label_block = InputHelpers.label_block(assigns)
    #  raw(~s(<div class="md-input-underline"></div>))

    InputHelpers.theme_module(assigns).wrap(
      [wrapped_input, label_block, error_block],
      :input_block,
      assigns
    )
  end

  def wrap(html, block_name, assigns) when is_atom(block_name) do
    my_classes = get_classes_for_element(block_name, assigns)

    if my_classes == nil do
      html_escape(MavuForm.process_html(html, block_name, assigns))
    else
      tag_options =
        MavuForm.get_tag_options_for_block(block_name, assigns)
        |> Keyword.put(:class, MavuForm.process_classes(my_classes, block_name, assigns))

      {tagname, tag_options} =
        case block_name do
          :wrapped_label ->
            {:label,
             tag_options
             |> Keyword.put(:for, Phoenix.HTML.Form.input_id(assigns.form, assigns.field))}

          _ ->
            {:div, tag_options}
        end

      content_tag(tagname, MavuForm.process_html(html, block_name, assigns), tag_options)
    end
  end

  def get_classes_for_element(block_name, assigns) when is_atom(block_name) and is_map(assigns) do
    case block_name do
      :container ->
        "font-sans text-xl w-full mt-4"

      :label_block ->
        nil

      :input_block ->
        "md-input-box relative"

      :wrapped_label ->
        case {assigns.type, assigns.has_error} do
          {:checkbox, true} -> "pl-2 text-sm font-normal text-red-600"
          {:checkbox, false} -> "pl-2 text-sm font-normal text-gray-600"
          {_, _} -> "md-label text-gray-400 text-sm"
        end

      :wrapped_input ->
        nil

      :raw_label ->
        ""

      :raw_input ->
        case {assigns.type, assigns.has_error} do
          {:checkbox, _} ->
            " ml-1 border-gray-300  shadow-sm focus:ring-indigo-500 focus:border-indigo-500  rounded text-indigo-700 "

          {_, false} ->
            " md-input w-full border-gray-400  focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded"

          {_, true} ->
            " md-input w-full text-red-900  border-red-300  focus:outline-none focus:ring-red-500 focus:border-red-500 sm:text-sm rounded"
        end
    end
  end

  def error_block(assigns) do
    assigns.form.errors
    |> Keyword.get_values(assigns.field)
    |> Enum.map(fn error ->
      content_tag(:p, "↑ " <> MyAppBe.ErrorHelpers.translate_error(error),
        class: "mt-2 text-sm text-red-600 invalid-feedback",
        data: [
          phx_error_for: input_id(assigns.form, assigns.field),
          phx_feedback_for: input_name(assigns.form, assigns.field)
        ]
      )
    end)
  end

  def mark_label_as_required(form, field, assigns) do
    validations = Phoenix.HTML.Form.input_validations(form, field)

    if true?(assigns.opts[:required]) or true?(validations[:required]) do
      [assigns.inner_content, raw(~s(<sup class="ml-1">*</sup>))]
    else
      assigns.inner_content
    end
  end
end
