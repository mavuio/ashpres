defmodule MyAppBe.BeAccounts.BeUserSessionControllerTest do
  use MyAppWeb.ConnCase, async: true

  import MyApp.BeAccountsFixtures

  setup do
    %{be_user: be_user_fixture()}
  end

  describe "POST /be/be_users/log_in" do
    test "logs the be_user in", %{conn: conn, be_user: be_user} do
      conn =
        post(conn, ~p"/be/be_users/log_in", %{
          "be_user" => %{"email" => be_user.email, "password" => valid_be_user_password()}
        })

      assert get_session(conn, :be_user_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ be_user.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the be_user in with remember me", %{conn: conn, be_user: be_user} do
      conn =
        post(conn, ~p"/be/be_users/log_in", %{
          "be_user" => %{
            "email" => be_user.email,
            "password" => valid_be_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_my_app_web_be_user_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the be_user in with return to", %{conn: conn, be_user: be_user} do
      conn =
        conn
        |> init_test_session(be_user_return_to: "/foo/bar")
        |> post(~p"/be/be_users/log_in", %{
          "be_user" => %{
            "email" => be_user.email,
            "password" => valid_be_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, be_user: be_user} do
      conn =
        conn
        |> post(~p"/be/be_users/log_in", %{
          "_action" => "registered",
          "be_user" => %{
            "email" => be_user.email,
            "password" => valid_be_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, be_user: be_user} do
      conn =
        conn
        |> post(~p"/be/be_users/log_in", %{
          "_action" => "password_updated",
          "be_user" => %{
            "email" => be_user.email,
            "password" => valid_be_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/be/be_users/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/be/be_users/log_in", %{
          "be_user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/be/be_users/log_in"
    end
  end

  describe "DELETE /be/be_users/log_out" do
    test "logs the be_user out", %{conn: conn, be_user: be_user} do
      conn = conn |> log_in_be_user(be_user) |> delete(~p"/be/be_users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :be_user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the be_user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/be/be_users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :be_user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
