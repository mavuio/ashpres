defmodule MyAppBe.BeAccounts.BeUserSessionController do
  use MyAppWeb, :controller

  alias MyApp.BeAccounts
  alias MyAppBe.BeAccounts.BeUserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:be_user_return_to, ~p"/be/be_users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"be_user" => be_user_params}, info) do
    %{"email" => email, "password" => password} = be_user_params

    with {:ok, be_user} <- BeAccounts.get_be_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> BeUserAuth.log_in_be_user(be_user, be_user_params)
    else
      {:error, :bad_username_or_password} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/be/be_users/log_in")

      {:error, :not_active} ->
        conn
        |> put_flash(:error, "your account is not active")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/be/be_users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> BeUserAuth.log_out_be_user()
  end
end
