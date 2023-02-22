defmodule MyApp.BeAccounts do
  @moduledoc """
  The BeAccounts context.
  """

  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.BeAccounts.{BeUser, BeUserToken, BeUserNotifier}

  use Phoenix.VerifiedRoutes, endpoint: MyAppWeb.Endpoint, router: MyAppWeb.Router

  ## Database getters

  @doc """
  Gets a be_user by email.

  ## Examples

      iex> get_be_user_by_email("foo@example.com")
      %BeUser{}

      iex> get_be_user_by_email("unknown@example.com")
      nil

  """
  def get_be_user_by_email(email) when is_binary(email) do
    Repo.get_by(BeUser, email: email)
  end

  @doc """
  Gets a be_user by email and password.

  ## Examples

      iex> get_be_user_by_email_and_password("foo@example.com", "correct_password")
      %BeUser{}

      iex> get_be_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_be_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    be_user = Repo.get_by(BeUser, email: email)
    # if BeUser.valid_password?(be_user, password), do: be_user

    cond do
      !BeUser.valid_password?(be_user, password) -> {:error, :bad_username_or_password}
      !BeUser.is_active?(be_user) -> {:error, :not_active}
      true -> {:ok, be_user}
    end
  end

  @doc """
  Gets a single be_user.

  Raises `Ecto.NoResultsError` if the BeUser does not exist.

  ## Examples

      iex> get_be_user!(123)
      %BeUser{}

      iex> get_be_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_be_user!(id), do: Repo.get!(BeUser, id)

  def get_user!(id), do: get_be_user!(id)
  ## Be user registration

  @doc """
  Registers a be_user.

  ## Examples

      iex> register_be_user(%{field: value})
      {:ok, %BeUser{}}

      iex> register_be_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_be_user(attrs) do
    %BeUser{}
    |> BeUser.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking be_user changes.

  ## Examples

      iex> change_be_user_registration(be_user)
      %Ecto.Changeset{data: %BeUser{}}

  """
  def change_be_user_registration(%BeUser{} = be_user, attrs \\ %{}) do
    BeUser.registration_changeset(be_user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the be_user email.

  ## Examples

      iex> change_be_user_email(be_user)
      %Ecto.Changeset{data: %BeUser{}}

  """
  def change_be_user_email(be_user, attrs \\ %{}) do
    BeUser.email_changeset(be_user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_be_user_email(be_user, "valid password", %{email: ...})
      {:ok, %BeUser{}}

      iex> apply_be_user_email(be_user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_be_user_email(be_user, password, attrs) do
    be_user
    |> BeUser.email_changeset(attrs)
    |> BeUser.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the be_user email using the given token.

  If the token matches, the be_user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_be_user_email(be_user, token) do
    context = "change:#{be_user.email}"

    with {:ok, query} <- BeUserToken.verify_change_email_token_query(token, context),
         %BeUserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(be_user_email_multi(be_user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp be_user_email_multi(be_user, email, context) do
    changeset =
      be_user
      |> BeUser.email_changeset(%{email: email})
      |> BeUser.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:be_user, changeset)
    |> Ecto.Multi.delete_all(:tokens, BeUserToken.be_user_and_contexts_query(be_user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given be_user.

  ## Examples

      iex> deliver_be_user_update_email_instructions(be_user, current_email, &url(~p"/be/be_users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_be_user_update_email_instructions(
        %BeUser{} = be_user,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, be_user_token} =
      BeUserToken.build_email_token(be_user, "change:#{current_email}")

    Repo.insert!(be_user_token)

    BeUserNotifier.deliver_update_email_instructions(
      be_user,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the be_user password.

  ## Examples

      iex> change_be_user_password(be_user)
      %Ecto.Changeset{data: %BeUser{}}

  """
  def change_be_user_password(be_user, attrs \\ %{}) do
    BeUser.password_changeset(be_user, attrs, hash_password: false)
  end

  @doc """
  Updates the be_user password.

  ## Examples

      iex> update_be_user_password(be_user, "valid password", %{password: ...})
      {:ok, %BeUser{}}

      iex> update_be_user_password(be_user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_be_user_password(be_user, password, attrs) do
    changeset =
      be_user
      |> BeUser.password_changeset(attrs)
      |> BeUser.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:be_user, changeset)
    |> Ecto.Multi.delete_all(:tokens, BeUserToken.be_user_and_contexts_query(be_user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{be_user: be_user}} -> {:ok, be_user}
      {:error, :be_user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_be_user_session_token(be_user) do
    {token, be_user_token} = BeUserToken.build_session_token(be_user)
    Repo.insert!(be_user_token)
    token
  end

  @doc """
  Gets the be_user with the given signed token.
  """
  def get_be_user_by_session_token(token) do
    {:ok, query} = BeUserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_be_user_session_token(token) do
    Repo.delete_all(BeUserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given be_user.

  ## Examples

      iex> deliver_be_user_confirmation_instructions(be_user, &url(~p"/be/be_users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_be_user_confirmation_instructions(confirmed_be_user, &url(~p"/be/be_users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_be_user_confirmation_instructions(%BeUser{} = be_user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if be_user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, be_user_token} = BeUserToken.build_email_token(be_user, "confirm")
      Repo.insert!(be_user_token)

      BeUserNotifier.deliver_confirmation_instructions(
        be_user,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Confirms a be_user by the given token.

  If the token matches, the be_user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_be_user(token) do
    with {:ok, query} <- BeUserToken.verify_email_token_query(token, "confirm"),
         %BeUser{} = be_user <- Repo.one(query),
         {:ok, %{be_user: be_user}} <- Repo.transaction(confirm_be_user_multi(be_user)) do
      {:ok, be_user}
    else
      _ -> :error
    end
  end

  defp confirm_be_user_multi(be_user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:be_user, BeUser.confirm_changeset(be_user))
    |> Ecto.Multi.delete_all(
      :tokens,
      BeUserToken.be_user_and_contexts_query(be_user, ["confirm"])
    )
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given be_user.

  ## Examples

      iex> deliver_be_user_reset_password_instructions(be_user, &url(~p"/be/be_users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_be_user_reset_password_instructions(%BeUser{} = be_user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, be_user_token} = BeUserToken.build_email_token(be_user, "reset_password")
    Repo.insert!(be_user_token)

    BeUserNotifier.deliver_reset_password_instructions(
      be_user,
      reset_password_url_fun.(encoded_token)
    )
  end

  def get_init_password_link(%BeUser{} = be_user) do
    {encoded_token, be_user_token} = BeUserToken.build_email_token(be_user, "init_password")
    Repo.insert!(be_user_token)

    url(~p"/be/be_users/init_password/#{encoded_token}")
  end

  def get_be_user_by_init_password_token(token) do
    with {:ok, query} <- BeUserToken.verify_email_token_query(token, "init_password"),
         %BeUser{} = be_user <- Repo.one(query) do
      be_user
    else
      _ -> nil
    end
  end

  def init_be_user_password(be_user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:be_user, BeUser.password_changeset(be_user, attrs))
    |> Ecto.Multi.delete_all(:tokens, BeUserToken.be_user_and_contexts_query(be_user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{be_user: be_user}} -> {:ok, be_user}
      {:error, :be_user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Gets the be_user by reset password token.

  ## Examples

      iex> get_be_user_by_reset_password_token("validtoken")
      %BeUser{}

      iex> get_be_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_be_user_by_reset_password_token(token) do
    with {:ok, query} <- BeUserToken.verify_email_token_query(token, "reset_password"),
         %BeUser{} = be_user <- Repo.one(query) do
      be_user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the be_user password.

  ## Examples

      iex> reset_be_user_password(be_user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %BeUser{}}

      iex> reset_be_user_password(be_user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_be_user_password(be_user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:be_user, BeUser.password_changeset(be_user, attrs))
    |> Ecto.Multi.delete_all(:tokens, BeUserToken.be_user_and_contexts_query(be_user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{be_user: be_user}} -> {:ok, be_user}
      {:error, :be_user, changeset, _} -> {:error, changeset}
    end
  end

  def get_query(_params, _context) do
    BeUser
    |> Ecto.Query.from()
  end

  def get_number_of_be_users() do
    Repo.aggregate(BeUser, :count)
  end

  def activate_user(be_user, new_value) when is_boolean(new_value) do
    be_user
    |> BeUser.activate_changeset(new_value)
    |> Repo.update!()
  end
end
