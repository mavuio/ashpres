defmodule MyAppBe.BeAccounts.BeUserConfirmationInstructionsLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.BeAccountsFixtures

  alias MyApp.BeAccounts
  alias MyApp.Repo

  setup do
    %{be_user: be_user_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/be/be_users/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, be_user: be_user} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", be_user: %{email: be_user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(BeAccounts.BeUserToken, be_user_id: be_user.id).context == "confirm"
    end

    test "does not send confirmation token if be_user is confirmed", %{
      conn: conn,
      be_user: be_user
    } do
      Repo.update!(BeAccounts.BeUser.confirm_changeset(be_user))

      {:ok, lv, _html} = live(conn, ~p"/be/be_users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", be_user: %{email: be_user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(BeAccounts.BeUserToken, be_user_id: be_user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", be_user: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(BeAccounts.BeUserToken) == []
    end
  end
end
