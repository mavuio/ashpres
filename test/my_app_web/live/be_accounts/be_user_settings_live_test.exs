defmodule MyAppBe.BeAccounts.BeUserSettingsLiveTest do
  use MyAppWeb.ConnCase

  alias MyApp.BeAccounts
  import Phoenix.LiveViewTest
  import MyApp.BeAccountsFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_be_user(be_user_fixture())
        |> live(~p"/be/be_users/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if be_user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/be/be_users/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/be/be_users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_be_user_password()
      be_user = be_user_fixture(%{password: password})
      %{conn: log_in_be_user(conn, be_user), be_user: be_user, password: password}
    end

    test "updates the be_user email", %{conn: conn, password: password, be_user: be_user} do
      new_email = unique_be_user_email()

      {:ok, lv, _html} = live(conn, ~p"/be/be_users/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "be_user" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert BeAccounts.get_be_user_by_email(be_user.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "be_user" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, be_user: be_user} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "be_user" => %{"email" => be_user.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_be_user_password()
      be_user = be_user_fixture(%{password: password})
      %{conn: log_in_be_user(conn, be_user), be_user: be_user, password: password}
    end

    test "updates the be_user password", %{conn: conn, be_user: be_user, password: password} do
      new_password = valid_be_user_password()

      {:ok, lv, _html} = live(conn, ~p"/be/be_users/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "be_user" => %{
            "email" => be_user.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/be/be_users/settings"

      assert get_session(new_password_conn, :be_user_token) != get_session(conn, :be_user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert BeAccounts.get_be_user_by_email_and_password(be_user.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "be_user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/be/be_users/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "be_user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      be_user = be_user_fixture()
      email = unique_be_user_email()

      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_update_email_instructions(
            %{be_user | email: email},
            be_user.email,
            url
          )
        end)

      %{conn: log_in_be_user(conn, be_user), token: token, email: email, be_user: be_user}
    end

    test "updates the be_user email once", %{
      conn: conn,
      be_user: be_user,
      token: token,
      email: email
    } do
      {:error, redirect} = live(conn, ~p"/be/be_users/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/be/be_users/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute BeAccounts.get_be_user_by_email(be_user.email)
      assert BeAccounts.get_be_user_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/be/be_users/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/be/be_users/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, be_user: be_user} do
      {:error, redirect} = live(conn, ~p"/be/be_users/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/be/be_users/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert BeAccounts.get_be_user_by_email(be_user.email)
    end

    test "redirects if be_user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/be/be_users/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/be/be_users/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
