defmodule MyAppBe.Components.SetTagsForItems do
  @moduledoc false
  use Phoenix.Component

  attr :phx_target, :any, required: true
  attr :selected_ids, :list, required: true
  attr :phx_click, :string, default: "set_tags_for_items"
  attr :context, :map

  attr :rest, :global,
    default: %{
      class: "p-4 mx-10 mt-4 tagbox bg-slate-50"
    }

  def tagbox(assigns) do
    ~H"""
    <style>
      @keyframes tagbox_appear {
        100% { opacity: 1; max-height: 300px}
      }
      .tagbox {
        animation: tagbox_appear 900ms 10ms ease-out forwards;
        opacity: 1; max-height:0px; overflow: hidden;
      }
    </style>

    <section :if={length(@selected_ids) > 0} {@rest}>
      <div class="pb-1 text-sm opacity-70">for all selected items:</div>

      <article class="flex items-center mb-2 space-x-4">
        <.live_component
          :let={chosen_tags}
          module={MyAppBe.AshtagChooserComponent}
          context={@context}
          id="add_tags"
          on_change="add_tags"
          class="flex items-center space-x-4"
        >
          <MyAppBe.CoreComponents.mybutton
            phx-click={@phx_click}
            phx-target={@phx_target}
            phx-value-type="add"
            phx-value-tag-ids={Enum.map(chosen_tags, & &1.id) |> Enum.join(",")}
            disabled={length(chosen_tags) == 0}
          >
            <Heroicons.plus_circle class="w-5 h-5 mr-1" /> add tags
          </MyAppBe.CoreComponents.mybutton>
        </.live_component>
      </article>

      <article class="flex items-center space-x-4">
        <.live_component
          :let={chosen_tags}
          module={MyAppBe.AshtagChooserComponent}
          context={@context}
          id="remove_tags"
          on_change="add_tags"
          class="flex items-center space-x-4"
        >
          <MyAppBe.CoreComponents.mybutton
            phx-click={@phx_click}
            phx-target={@phx_target}
            phx-value-type="remove"
            phx-value-tag-ids={Enum.map(chosen_tags, & &1.id) |> Enum.join(",")}
            disabled={length(chosen_tags) == 0}
          >
            <Heroicons.minus_circle class="w-5 h-5 mr-1" /> remove tags
          </MyAppBe.CoreComponents.mybutton>
        </.live_component>
      </article>
    </section>
    """
  end
end
