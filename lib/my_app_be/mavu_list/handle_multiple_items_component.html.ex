defmodule MyAppBe.MavuList.HandleMultipleItemsComponent do
  @moduledoc false
  use Phoenix.Component

  attr :selected_ids, :list, required: true

  attr :rest, :global,
    default: %{
      class: "p-4 mx-10 mt-4 multi_buttonbox bg-slate-50"
    }

  slot :inner_block, required: true

  def buttonbox(assigns) do
    ~H"""
    <style>
      @keyframes multi_buttonbox_appear {
        100% { opacity: 1; max-height: 300px}
      }
      .multi_buttonbox {
        animation: multi_buttonbox_appear 900ms 10ms ease-out forwards;
        opacity: 1; max-height:0px; overflow: hidden;
      }
    </style>

    <section :if={length(@selected_ids) > 0} {@rest}>
      <div class="pb-1 text-sm opacity-70">
        for <%= length(@selected_ids) %> selected item<span :if={length(@selected_ids) > 1}>s</span>:
      </div>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end
end
