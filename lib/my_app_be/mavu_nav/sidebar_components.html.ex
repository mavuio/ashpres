defmodule MyAppBe.MavuNav.SidebarComponents do
  use Phoenix.Component

  slot(:inner_block, required: true)

  slot(:content, required: true)

  attr(:menu, :list)
  slot(:sidebar_header)
  slot(:sidebar_footer)

  def container(assigns) do
    assigns =
      assigns
      |> assign(content: assigns.content |> hd())

    ~H"""
    <div
      id="application"
      class="bg-white mavu_sb-page"
      x-data="mavu_sidebar()"
      x-bind:class="{'sb-is_open': isOpen,'sb-is_pinned': isPinned }"
    >
      <div class="mavu_sb-topcontainer" style="transition-property: left" id="content_w_sidebar">
        <.sidebar menu={assigns[:menu]} usermenu={assigns[:usermenu]} user="assigns[:user]">
          <:header_content><%= render_slot(@sidebar_header) || "Backend" %></:header_content>
          <:footer_content><%= render_slot(@sidebar_footer) %></:footer_content>
        </.sidebar>

        <.content>
          <%= render_slot(@content) %>
        </.content>
      </div>
    </div>
    """
  end

  attr(:menu, :map)
  slot(:inner_block, required: false, default: nil)
  slot(:header)
  slot(:footer)
  slot(:header_content)
  slot(:footer_content)

  def sidebar(assigns) do
    ~H"""
    <nav id="sidebar" class="mavu_sb-sidebar">
      <div class="ms-inner">
        <%= if @header != [] do %>
          <%= render_slot(@header) %>
        <% else %>
          <.sidebar_header link={@menu.opts[:home_url]}>
            <%= render_slot(@header_content) || "Backend" %>
          </.sidebar_header>
        <% end %>

        <%= if @menu do %>
          <MyAppBe.MavuNav.MenuComponents.menu menu={@menu} class="ms-content" />
        <% end %>

        <%= if assigns[:inner_block] do %>
          <%= render_slot(@inner_block) %>
        <% end %>

        <%= if @footer != [] do %>
          <%= render_slot(@footer) %>
        <% else %>
          <div x-data="{footernav_open: false}">
            <.sidebar_footer>
              <%= render_slot(@footer_content) %>
            </.sidebar_footer>
            <%= if @usermenu do %>
              <MyAppBe.MavuNav.MenuComponents.menu
                menu={@usermenu}
                class="ms-footernav"
                x-show="footernav_open"
                x-collapse
                x-cloak
              />
            <% end %>
          </div>
        <% end %>
      </div>
    </nav>
    """
  end

  slot(:inner_block, required: true)
  attr(:link, :string, required: true)

  def sidebar_header(assigns) do
    ~H"""
    <div class="ms-header">
      <.link navigate={@link} class="ms-header-content"><%= render_slot(@inner_block) %></.link>
      <.pin_button />
    </div>
    """
  end

  slot(:inner_block, required: true)
  attr(:rest, :global)

  def sidebar_footer(assigns) do
    ~H"""
    <div class="ms-footer" x-on:click="footernav_open = !footernav_open">
      <div class="ms-footer-content"><%= render_slot(@inner_block) %></div>
      <.expand_button />
    </div>
    """
  end

  slot(:inner_block, required: true)

  def content(assigns) do
    ~H"""
    <div class="mavu_sb-content">
      <.sidebar_toggler />

      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def expand_button(assigns) do
    ~H"""
    <button>
      <Heroicons.chevron_down class="c-down" x-show="!footernav_open" />
      <Heroicons.chevron_up class="c-up" x-show="footernav_open" />
    </button>
    """
  end

  def pin_button(assigns) do
    ~H"""
    <div class="relative w-10 pt-5 text-white cursor-pointer group" x-on:click="togglePin()">
      <div
        class="absolute top-0 right-0"
        x-bind:class="!isPinned ? 'group-hover:opacity-0' : 'opacity-0 group-hover:opacity-100'"
      >
        <.unpinned_icon class="w-5 h-5" />
      </div>
      <div
        class="absolute top-0 right-0"
        x-bind:class="isPinned ? 'group-hover:opacity-0' : 'opacity-0 group-hover:opacity-100'"
      >
        <.pinned_icon class="w-5 h-5" />
      </div>
    </div>
    """
  end

  def sidebar_toggler(assigns) do
    ~H"""
    <div
      class="bg-[#52b6ca] text-white absolute left-0  top-0 p-5 cursor-pointer z-50"
      x-on:click="toggleOpen()"
      x-show="!isPinned"
    >
      <Heroicons.bars_3 class="w-5 h-5" x-show="!isOpen" />
      <Heroicons.x_mark class="w-5 h-5" x-show="isOpen" />
    </div>
    """
  end

  def pinned_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class={@class}
      width="24"
      height="24"
      viewBox="0 0 24 24"
      stroke-width="2"
      stroke="currentColor"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
      <path d="M9 4v6l-2 4v2h10v-2l-2 -4v-6"></path>
      <line x1="12" y1="16" x2="12" y2="21"></line>
      <line x1="8" y1="4" x2="16" y2="4"></line>
    </svg>
    """
  end

  def unpinned_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class={@class}
      width="24"
      height="24"
      viewBox="0 0 24 24"
      stroke-width="2"
      stroke="currentColor"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
      <line x1="3" y1="3" x2="21" y2="21"></line>
      <path d="M15 4.5l-3.249 3.249m-2.57 1.433l-2.181 .818l-1.5 1.5l7 7l1.5 -1.5l.82 -2.186m1.43 -2.563l3.25 -3.251">
      </path>
      <line x1="9" y1="15" x2="4.5" y2="19.5"></line>
      <line x1="14.5" y1="4" x2="20" y2="9.5"></line>
    </svg>
    """
  end

  def sidebar_code(assigns) do
    ~H"""
    <script>
      (() => {

          const defineComponent = () => {

            const setCookie = (name, value, days = 7, path = '/') => {
            const expires = new Date(Date.now() + days * 864e5).toUTCString()
              document.cookie = name + '=' + encodeURIComponent(value) + '; expires=' + expires + '; path=' + path
            }

            const getCookie = (name) => {
              return document.cookie.split('; ').reduce((r, v) => {
                const parts = v.split('=')
                return parts[0] === name ? decodeURIComponent(parts[1]) : r
              }, '')
            }

            const deleteCookie = (name, path) => {
              setCookie(name, '', -1, path)
            }

              Alpine.data('mavu_sidebar', () => ({
                isOpen:true,
                isPinned:true,
                toggleOpen(){
                  this.isOpen=!this.isOpen;
                },
                closeSidebar(){
                  if(!this.isPinned) {
                    this.isOpen=false;
                  }
                },
                togglePin(){
                  if (this.isPinned){
                    this.isOpen=false
                    this.isPinned=false;
                  } else
                  {
                    this.isOpen=true;
                    this.isPinned=true;
                  }
                  this.updatePinCookie();
                },
                updatePinCookie(){
                  var expDate = new Date();
                  expDate.setTime(expDate.getTime() + (365 * 24 * 3600 * 1000));
                  if (this.isPinned){
                    setCookie('nav_pinned','yes');
                  } else {
                    setCookie('nav_pinned','no');
                  }
                },
                init() {
                  let val=getCookie('nav_pinned')
                  if(val=="yes") {
                    this.isPinned=true;
                    this.isOpen=true;
                  }
                  if(val=="no") {
                    this.isPinned=false;
                    this.isOpen=false;
                  }
                }

              }));
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
