defmodule MyAppBe.BeAccounts.BeUserForgotPasswordLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.BeAccountsFixtures

  alias MyApp.BeAccounts
  alias MyApp.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/be/be_users/reset_password")

      assert html =~ "Forgot your password?"
      assert html =~ "Register</a>"
      assert html =~ "Log in</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_be_user(be_user_fixture())
        |> live(~p"/be/be_users/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, be_user: be_user} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", be_user: %{"email" => be_user.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(BeAccounts.BeUserToken, be_user_id: be_user.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", be_user: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(BeAccounts.BeUserToken) == []
    end
  end
end
