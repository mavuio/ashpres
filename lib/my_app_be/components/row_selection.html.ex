defmodule MyAppBe.Components.RowSelection do
  @moduledoc false
  use Phoenix.Component

  attr :rest, :global,
    default: %{
      class: "w-5 h-5 m-1 inline-block cursor-pointer hover:opacity-100 opacity-60",
      phx_click: "toggle_row_selection"
    }

  attr :row_id, :any, required: true
  attr :selected_ids, :list, required: true
  attr :phx_target, :string, required: true

  slot :checked
  slot :unchecked

  def toggler(%{row_id: :all} = assigns) do
    assigns = put_in(assigns, [:rest, :phx_target], assigns[:phx_target])

    if length(assigns.selected_ids) > 0 do
      assigns = put_in(assigns, [:rest, :phx_value_toggle], "none")

      ~H"""
      <%= render_slot(@checked) || default_checked(assigns) %>
      """
    else
      assigns = put_in(assigns, [:rest, :phx_value_toggle], "all")

      ~H"""
      <%= render_slot(@unchecked) || default_unchecked(assigns) %>
      """
    end
  end

  def toggler(assigns) do
    assigns = put_in(assigns, [:rest, :phx_target], assigns[:phx_target])

    if Enum.member?(assigns.selected_ids, to_string(assigns.row_id)) do
      assigns = put_in(assigns, [:rest, :phx_value_remove_id], assigns.row_id)

      ~H"""
      <%= render_slot(@checked) || default_checked(assigns) %>
      """
    else
      assigns = put_in(assigns, [:rest, :phx_value_add_id], assigns.row_id)

      ~H"""
      <%= render_slot(@unchecked) || default_unchecked(assigns) %>
      """
    end
  end

  def default_checked(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" {@rest}>
      <path
        fill-rule="evenodd"
        d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  def default_unchecked(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" {@rest}>
      <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="#{opts[:stroke_width] || 4}">
      </circle>
    </svg>
    """
  end
end
