defmodule MyAppBe.MavuList.LabelComponent do
  @moduledoc false
  use Phoenix.Component

  def paint(%{list: list, name: name} = base_assigns) do
    assigns =
      Map.merge(
        base_assigns,
        MavuList.generate_assigns_for_label_component(list, name)
      )

    if assigns[:is_user_sortable] do
      ~H(
<a href="#" class="inline-flex items-center space-x-2" phx-click="list.toggle_column" phx-value-name={"#{@name}"}
  phx-throttle="500" phx-target={"#{@target}"}>
  <span class="uppercase"><%= @label  %></span>

  <% class= case @direction do
      :asc->"rotate-0"
      :desc->"rotate-180"
      nil->"rotate-0"
      end
  %>

  <button type="button"
    class={"inline-flex items-center p-1 text-gray-400 rotate-180 bg-transparent border border-transparent rounded-full shadow-sm hover:bg-gray-200 focus:outline-none   #{unless @direction do
        "opacity-0 hover:opacity-100"
      end}"}>
    <svg class={"w-4 h-4  transition-transform transform duration-300 #{class}"} fill="currentColor"
      viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
      <path fill-rule="evenodd"
        d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L11 5.414V17a1 1 0 11-2 0V5.414L4.707 9.707a1 1 0 01-1.414 0z"
        clip-rule="evenodd"></path>
    </svg>
  </button>
</a>)
    else
      ~H"""
      <div class="inline-flex items-center space-x-2 uppercase"><span><%= @label  %></span></div>
      """
    end
  end
end
