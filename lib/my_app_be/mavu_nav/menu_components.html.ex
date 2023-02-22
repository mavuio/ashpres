defmodule MyAppBe.MavuNav.MenuComponents do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS

  @doc """
  Renders a tree-like menu

  """

  attr :menu, :map, required: true
  attr :class, :string, required: true
  attr :rest, :global

  def menu(assigns) do
    ~H"""
    <nav
      class={"mavu_menu " <> @class}
      x-data={"mavu_menu(#{@menu.opts  |> Map.new() |> Jason.encode!()})"}
      {@rest}
    >
      <%!-- <span x-text="open_group"></span> --%>
      <%= for {topitem,idx} <- @menu.links  |> Enum.with_index(1) do %>
        <%= if topitem[:children] do %>
          <div
            class="mm_navgroup"
            data-idx={idx}
            x-bind:class={"{'is-open': open_group==#{idx},'is-active': active_group==#{idx} }"}
          >
            <div class="mm_navgroup-title" x-on:click={"toggleGroup(#{idx})"}>
              <span><.link_body label={topitem.label} icon={topitem[:icon]} /></span>

              <button>
                <Heroicons.chevron_right class="c-right" />
                <Heroicons.chevron_down class="c-down" />
              </button>
            </div>
            <div class="mm_navgroup-items" x-show={"open_group==#{idx}"} x-collapse x-cloak>
              <%= for {subitem,_subidx} <- topitem.children  |> Enum.with_index() do %>
                <.link
                  class="mm_link"
                  {subitem |> Map.drop(~w(children icon)a) |> Map.to_list()}
                  x-on:click="closeSidebar()"
                >
                  <.link_body label={subitem.label} icon={subitem[:icon]} />
                </.link>
              <% end %>
            </div>
          </div>
        <% else %>
          <.link
            class="mm_link"
            {topitem  |>  Map.drop(~w(icon)a)  |> Map.to_list()}
            x-on:click="closeSidebar()"
          >
            <.link_body label={topitem.label} icon={topitem[:icon]} />
          </.link>
        <% end %>
      <% end %>
    </nav>
    """
  end

  attr :label, :string, required: true
  attr :icon, :any, required: true

  def link_body(assigns) do
    ~H"""
    <%= if @icon do %>
      <div class="flex items-center space-x-2">
        <%= @icon.(%{__changed__: nil, class: "w-4 h-4"}) %>
        <span><%= @label %></span>
      </div>
    <% else %>
      <%= @label %>
    <% end %>
    """
  end

  def menu_code(assigns) do
    ~H"""
    <script>
      (() => {
          const defineComponent = () => {
              Alpine.data('mavu_menu', (opts) => ({
                open_group: 0,
                active_group: 0,
                init() {
                  console.log('#log 2742 init menu',opts);
                  this.open_active_navgroup();
                  this.setupEventListener();
                },
                toggleGroup(idx) {
                  if(this.open_group==idx) {
                    this.open_group=0;
                  } else {
                    this.open_group=idx;
                  }

                },
                setupEventListener() {
                  window.addEventListener(`phx:url_changed`, (e) => {
                    const new_url=e.detail.url;
                    const el=this.find_link_for_new_url(new_url);
                    this.deactivate_all();
                    this.activate_link(el);
                    this.open_active_navgroup();
                    });
                },
                deactivate_all() {
                  this.active_group=0;
                  let old_active_els=this.$el.querySelectorAll('.mm_link.is-active');
                  Array.from(old_active_els).forEach( el => el.classList.remove("is-active") );
                },
                activate_link(el) {
                  if(el) {
                    el.classList.add("is-active");
                  }
                },
                open_active_navgroup() {
                  let active_el=this.$el.querySelector('.mm_link.is-active');
                  if(active_el) {
                    this.active_group=this.open_group=active_el.parentElement.parentElement.dataset.idx;
                  }
                },
                find_link_for_new_url(new_url) {
                  const strict_match=this.$el.querySelector(`.mm_link[href="${new_url}"]`);
                  if(strict_match) {
                    return strict_match;
                  }

                  if(opts['strict_matches'] && opts.strict_matches.includes(new_url)) {
                      return null;
                  }

                  const loose_matches=Array.from(this.$el.querySelectorAll(`.mm_link[href^="${new_url}"]`));
                  if(loose_matches.length>0){
                    return loose_matches
                          .sort((a, b) => a.getAttribute("href").length - b.getAttribute("href").length)
                          .shift();
                  }
                  return null;
                }
              }
              )
            );
          };
          if (window.Alpine) {
              defineComponent.apply();
          } else {
              document.addEventListener('alpine:init', defineComponent)
          }
      })();
    </script>
    """
  end
end
