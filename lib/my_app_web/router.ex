defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  import MyAppBe.BeAccounts.BeUserAuth
  import AshAdmin.Router

  @default_be_live_hooks [MyAppBe.LiveHooks.InitContext, MyAppBe.LiveHooks.InitMenuSync]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MyAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_be_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_belayout do
    plug(:put_root_layout, {MyAppBe.Layouts, :be_root})
    plug(:put_layout, {MyAppBe.Layouts, :be_app})
  end

  scope "/", MyAppWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/" do
    pipe_through :browser

    ash_admin("/admin")
  end

  scope "/api/json" do
    pipe_through(:api)

    forward "/", MyAppWeb.JsonapiRouter
  end

  scope "/" do
    forward "/gql", Absinthe.Plug, schema: MyApp.Schema

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: MyApp.Schema,
            interface: :playground
  end

  ## Backend routes

  scope "/be", MyAppBe do
    pipe_through :browser
    pipe_through :require_belayout
    pipe_through :require_authenticated_be_user

    live_session :be_user_is_authenticated,
      on_mount:
        [
          {MyAppBe.BeAccounts.BeUserAuth, :ensure_authenticated}
        ] ++ @default_be_live_hooks do
      live "/", BackendIndexLive, :index
      live "/be_user_manager", BeUserUi.BeUserLive, :index
      live "/rodents", RodentsLive, :index
      live "/birds", BirdsLive, :index
      live("/tags/", AshtagsLive, :index)

      live "/be_users/settings", BeAccounts.BeUserSettingsLive, :edit

      live "/be_users/settings/confirm_email/:token",
           BeAccounts.BeUserSettingsLive,
           :confirm_email
    end
  end

  ##  Backend-Authentication basic routes

  scope "/be", MyAppBe.BeAccounts, as: :be do
    pipe_through [:browser, :redirect_if_be_user_is_authenticated]

    live_session :redirect_if_be_user_is_authenticated,
      on_mount:
        [
          {MyAppBe.BeAccounts.BeUserAuth, :redirect_if_be_user_is_authenticated}
        ] ++ @default_be_live_hooks do
      live "/be_users/register", BeUserRegistrationLive, :new
      live "/be_users/log_in", BeUserLoginLive, :new
      live "/be_users/reset_password", BeUserForgotPasswordLive, :new
      live "/be_users/reset_password/:token", BeUserResetPasswordLive, :edit
      live "/be_users/init_password", BeUserInitPasswordLive, :new
      live "/be_users/init_password/:token", BeUserInitPasswordLive, :edit
    end

    post "/be_users/log_in", BeUserSessionController, :create
  end

  ##  Backend-Authentication special routes

  scope "/be", MyAppBe.BeAccounts, as: :be do
    pipe_through [:browser, :require_belayout]

    delete "/be_users/log_out", BeUserSessionController, :delete

    live_session :current_be_user,
      on_mount:
        [{MyAppBe.BeAccounts.BeUserAuth, :mount_current_be_user}] ++ @default_be_live_hooks do
      live "/be_users/confirm/:token", BeUserConfirmationLive, :edit
      live "/be_users/confirm", BeUserConfirmationInstructionsLive, :new
    end
  end
end
