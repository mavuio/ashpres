defmodule MyAppBe.BeAccounts.BeUserRegistrationLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.BeAccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/be/be_users/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_be_user(be_user_fixture())
        |> live(~p"/be/be_users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(be_user: %{"email" => "with spaces", "password" => "too short"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end
  end

  describe "register be_user" do
    test "creates account and logs the be_user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/register")

      email = unique_be_user_email()
      form = form(lv, "#registration_form", be_user: valid_be_user_attributes(email: email))
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/register")

      be_user = be_user_fixture(%{email: "test@email.com"})

      lv
      |> form("#registration_form",
        be_user: %{"email" => be_user.email, "password" => "valid_password"}
      )
      |> render_submit() =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/be/be_users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
