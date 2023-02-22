defmodule MyAppBe.Navigation do
  use Phoenix.VerifiedRoutes, endpoint: MyAppWeb.Endpoint, router: MyAppWeb.Router

  import Phoenix.HTML

  def get_menu() do
    %{
      opts: [
        strict_matches: ~w(/be),
        home_url: ~p"/be"
      ],
      links: [
        %{label: "home", navigate: ~p"/be"},
        %{label: "Rodents", navigate: ~p"/be/rodents"},
        %{label: "Birds", navigate: ~p"/be/birds"},
        %{label: "Tags", navigate: ~p"/be/tags"},
        %{label: "Backend-Users", navigate: ~p"/be/be_user_manager"}
      ]
    }
  end

  def get_usermenu() do
    %{
      opts: [
        strict_matches: ~w(/be)
      ],
      links: [
        %{label: "User Settings", navigate: ~p"/be/be_users/settings"},
        %{label: "log out", href: ~p"/be/be_users/log_out", method: "delete"}
      ]
    }
  end
end
