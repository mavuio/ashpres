defmodule MyAppBe.BeAccounts.BeUserAuthTest do
  use MyAppWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias MyApp.BeAccounts
  alias MyAppBe.BeAccounts.BeUserAuth
  import MyApp.BeAccountsFixtures

  @remember_me_cookie "_my_app_web_be_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, MyAppWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{be_user: be_user_fixture(), conn: conn}
  end

  describe "log_in_be_user/3" do
    test "stores the be_user token in the session", %{conn: conn, be_user: be_user} do
      conn = BeUserAuth.log_in_be_user(conn, be_user)
      assert token = get_session(conn, :be_user_token)
      assert get_session(conn, :live_socket_id) == "be_users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert BeAccounts.get_be_user_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, be_user: be_user} do
      conn = conn |> put_session(:to_be_removed, "value") |> BeUserAuth.log_in_be_user(be_user)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, be_user: be_user} do
      conn =
        conn |> put_session(:be_user_return_to, "/hello") |> BeUserAuth.log_in_be_user(be_user)

      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, be_user: be_user} do
      conn =
        conn |> fetch_cookies() |> BeUserAuth.log_in_be_user(be_user, %{"remember_me" => "true"})

      assert get_session(conn, :be_user_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :be_user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_be_user/1" do
    test "erases session and cookies", %{conn: conn, be_user: be_user} do
      be_user_token = BeAccounts.generate_be_user_session_token(be_user)

      conn =
        conn
        |> put_session(:be_user_token, be_user_token)
        |> put_req_cookie(@remember_me_cookie, be_user_token)
        |> fetch_cookies()
        |> BeUserAuth.log_out_be_user()

      refute get_session(conn, :be_user_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute BeAccounts.get_be_user_by_session_token(be_user_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "be_users_sessions:abcdef-token"
      MyAppWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> BeUserAuth.log_out_be_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if be_user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> BeUserAuth.log_out_be_user()
      refute get_session(conn, :be_user_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_be_user/2" do
    test "authenticates be_user from session", %{conn: conn, be_user: be_user} do
      be_user_token = BeAccounts.generate_be_user_session_token(be_user)

      conn =
        conn |> put_session(:be_user_token, be_user_token) |> BeUserAuth.fetch_current_be_user([])

      assert conn.assigns.current_be_user.id == be_user.id
    end

    test "authenticates be_user from cookies", %{conn: conn, be_user: be_user} do
      logged_in_conn =
        conn |> fetch_cookies() |> BeUserAuth.log_in_be_user(be_user, %{"remember_me" => "true"})

      be_user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> BeUserAuth.fetch_current_be_user([])

      assert conn.assigns.current_be_user.id == be_user.id
      assert get_session(conn, :be_user_token) == be_user_token

      assert get_session(conn, :live_socket_id) ==
               "be_users_sessions:#{Base.url_encode64(be_user_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, be_user: be_user} do
      _ = BeAccounts.generate_be_user_session_token(be_user)
      conn = BeUserAuth.fetch_current_be_user(conn, [])
      refute get_session(conn, :be_user_token)
      refute conn.assigns.current_be_user
    end
  end

  describe "on_mount: mount_current_be_user" do
    test "assigns current_be_user based on a valid be_user_token ", %{
      conn: conn,
      be_user: be_user
    } do
      be_user_token = BeAccounts.generate_be_user_session_token(be_user)
      session = conn |> put_session(:be_user_token, be_user_token) |> get_session()

      {:cont, updated_socket} =
        BeUserAuth.on_mount(:mount_current_be_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_be_user.id == be_user.id
    end

    test "assigns nil to current_ be_user assign if there isn't a valid be_user_token ", %{
      conn: conn
    } do
      be_user_token = "invalid_token"
      session = conn |> put_session(:be_user_token, be_user_token) |> get_session()

      {:cont, updated_socket} =
        BeUserAuth.on_mount(:mount_current_be_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_be_user == nil
    end

    test "assigns nil to current_ be_user assign if there isn't a be_user_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        BeUserAuth.on_mount(:mount_current_be_user, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_be_user == nil
    end
  end

  describe "on_mount: ensure_authenticated" do
    test "authenticates current_be_user based on a valid be_user_token ", %{
      conn: conn,
      be_user: be_user
    } do
      be_user_token = BeAccounts.generate_be_user_session_token(be_user)
      session = conn |> put_session(:be_user_token, be_user_token) |> get_session()

      {:cont, updated_socket} =
        BeUserAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_be_user.id == be_user.id
    end

    test "redirects to login page if there isn't a valid be_user_token ", %{conn: conn} do
      be_user_token = "invalid_token"
      session = conn |> put_session(:be_user_token, be_user_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: MyAppWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = BeUserAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_be_user == nil
    end

    test "redirects to login page if there isn't a be_user_token ", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: MyAppWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = BeUserAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_be_user == nil
    end
  end

  describe "on_mount: :redirect_if_be_user_is_authenticated" do
    test "redirects if there is an authenticated  be_user ", %{conn: conn, be_user: be_user} do
      be_user_token = BeAccounts.generate_be_user_session_token(be_user)
      session = conn |> put_session(:be_user_token, be_user_token) |> get_session()

      assert {:halt, _updated_socket} =
               BeUserAuth.on_mount(
                 :redirect_if_be_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "Don't redirect is there is no authenticated be_user", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               BeUserAuth.on_mount(
                 :redirect_if_be_user_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_be_user_is_authenticated/2" do
    test "redirects if be_user is authenticated", %{conn: conn, be_user: be_user} do
      conn =
        conn
        |> assign(:current_be_user, be_user)
        |> BeUserAuth.redirect_if_be_user_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if be_user is not authenticated", %{conn: conn} do
      conn = BeUserAuth.redirect_if_be_user_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_be_user/2" do
    test "redirects if be_user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> BeUserAuth.require_authenticated_be_user([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/be/be_users/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> BeUserAuth.require_authenticated_be_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :be_user_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> BeUserAuth.require_authenticated_be_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :be_user_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> BeUserAuth.require_authenticated_be_user([])

      assert halted_conn.halted
      refute get_session(halted_conn, :be_user_return_to)
    end

    test "does not redirect if be_user is authenticated", %{conn: conn, be_user: be_user} do
      conn =
        conn |> assign(:current_be_user, be_user) |> BeUserAuth.require_authenticated_be_user([])

      refute conn.halted
      refute conn.status
    end
  end
end
