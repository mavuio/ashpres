defmodule MyAppBe.BeAccounts.BeUserConfirmationLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.BeAccountsFixtures

  alias MyApp.BeAccounts
  alias MyApp.Repo

  setup do
    %{be_user: be_user_fixture()}
  end

  describe "Confirm be_user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/be/be_users/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, be_user: be_user} do
      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_confirmation_instructions(be_user, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/be/be_users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "BeUser confirmed successfully"

      assert BeAccounts.get_be_user!(be_user.id).confirmed_at
      refute get_session(conn, :be_user_token)
      assert Repo.all(BeAccounts.BeUserToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "BeUser confirmation link is invalid or it has expired"

      # when logged in
      {:ok, lv, _html} =
        build_conn()
        |> log_in_be_user(be_user)
        |> live(~p"/be/be_users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, be_user: be_user} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "BeUser confirmation link is invalid or it has expired"

      refute BeAccounts.get_be_user!(be_user.id).confirmed_at
    end
  end
end
