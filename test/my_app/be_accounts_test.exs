defmodule MyApp.BeAccountsTest do
  use MyApp.DataCase

  alias MyApp.BeAccounts

  import MyApp.BeAccountsFixtures
  alias MyApp.BeAccounts.{BeUser, BeUserToken}

  describe "get_be_user_by_email/1" do
    test "does not return the be_user if the email does not exist" do
      refute BeAccounts.get_be_user_by_email("unknown@example.com")
    end

    test "returns the be_user if the email exists" do
      %{id: id} = be_user = be_user_fixture()
      assert %BeUser{id: ^id} = BeAccounts.get_be_user_by_email(be_user.email)
    end
  end

  describe "get_be_user_by_email_and_password/2" do
    test "does not return the be_user if the email does not exist" do
      refute BeAccounts.get_be_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the be_user if the password is not valid" do
      be_user = be_user_fixture()
      refute BeAccounts.get_be_user_by_email_and_password(be_user.email, "invalid")
    end

    test "returns the be_user if the email and password are valid" do
      %{id: id} = be_user = be_user_fixture()

      assert %BeUser{id: ^id} =
               BeAccounts.get_be_user_by_email_and_password(be_user.email, valid_be_user_password())
    end
  end

  describe "get_be_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        BeAccounts.get_be_user!(-1)
      end
    end

    test "returns the be_user with the given id" do
      %{id: id} = be_user = be_user_fixture()
      assert %BeUser{id: ^id} = BeAccounts.get_be_user!(be_user.id)
    end
  end

  describe "register_be_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = BeAccounts.register_be_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = BeAccounts.register_be_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = BeAccounts.register_be_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = be_user_fixture()
      {:error, changeset} = BeAccounts.register_be_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = BeAccounts.register_be_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers be_users with a hashed password" do
      email = unique_be_user_email()
      {:ok, be_user} = BeAccounts.register_be_user(valid_be_user_attributes(email: email))
      assert be_user.email == email
      assert is_binary(be_user.hashed_password)
      assert is_nil(be_user.confirmed_at)
      assert is_nil(be_user.password)
    end
  end

  describe "change_be_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = BeAccounts.change_be_user_registration(%BeUser{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_be_user_email()
      password = valid_be_user_password()

      changeset =
        BeAccounts.change_be_user_registration(
          %BeUser{},
          valid_be_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_be_user_email/2" do
    test "returns a be_user changeset" do
      assert %Ecto.Changeset{} = changeset = BeAccounts.change_be_user_email(%BeUser{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_be_user_email/3" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "requires email to change", %{be_user: be_user} do
      {:error, changeset} = BeAccounts.apply_be_user_email(be_user, valid_be_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{be_user: be_user} do
      {:error, changeset} =
        BeAccounts.apply_be_user_email(be_user, valid_be_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{be_user: be_user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        BeAccounts.apply_be_user_email(be_user, valid_be_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{be_user: be_user} do
      %{email: email} = be_user_fixture()
      password = valid_be_user_password()

      {:error, changeset} = BeAccounts.apply_be_user_email(be_user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{be_user: be_user} do
      {:error, changeset} =
        BeAccounts.apply_be_user_email(be_user, "invalid", %{email: unique_be_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{be_user: be_user} do
      email = unique_be_user_email()
      {:ok, be_user} = BeAccounts.apply_be_user_email(be_user, valid_be_user_password(), %{email: email})
      assert be_user.email == email
      assert BeAccounts.get_be_user!(be_user.id).email != email
    end
  end

  describe "deliver_be_user_update_email_instructions/3" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "sends token through notification", %{be_user: be_user} do
      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_update_email_instructions(be_user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert be_user_token = Repo.get_by(BeUserToken, token: :crypto.hash(:sha256, token))
      assert be_user_token.be_user_id == be_user.id
      assert be_user_token.sent_to == be_user.email
      assert be_user_token.context == "change:current@example.com"
    end
  end

  describe "update_be_user_email/2" do
    setup do
      be_user = be_user_fixture()
      email = unique_be_user_email()

      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_update_email_instructions(%{be_user | email: email}, be_user.email, url)
        end)

      %{be_user: be_user, token: token, email: email}
    end

    test "updates the email with a valid token", %{be_user: be_user, token: token, email: email} do
      assert BeAccounts.update_be_user_email(be_user, token) == :ok
      changed_be_user = Repo.get!(BeUser, be_user.id)
      assert changed_be_user.email != be_user.email
      assert changed_be_user.email == email
      assert changed_be_user.confirmed_at
      assert changed_be_user.confirmed_at != be_user.confirmed_at
      refute Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end

    test "does not update email with invalid token", %{be_user: be_user} do
      assert BeAccounts.update_be_user_email(be_user, "oops") == :error
      assert Repo.get!(BeUser, be_user.id).email == be_user.email
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end

    test "does not update email if be_user email changed", %{be_user: be_user, token: token} do
      assert BeAccounts.update_be_user_email(%{be_user | email: "current@example.com"}, token) == :error
      assert Repo.get!(BeUser, be_user.id).email == be_user.email
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end

    test "does not update email if token expired", %{be_user: be_user, token: token} do
      {1, nil} = Repo.update_all(BeUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert BeAccounts.update_be_user_email(be_user, token) == :error
      assert Repo.get!(BeUser, be_user.id).email == be_user.email
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end
  end

  describe "change_be_user_password/2" do
    test "returns a be_user changeset" do
      assert %Ecto.Changeset{} = changeset = BeAccounts.change_be_user_password(%BeUser{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        BeAccounts.change_be_user_password(%BeUser{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_be_user_password/3" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "validates password", %{be_user: be_user} do
      {:error, changeset} =
        BeAccounts.update_be_user_password(be_user, valid_be_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{be_user: be_user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        BeAccounts.update_be_user_password(be_user, valid_be_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{be_user: be_user} do
      {:error, changeset} =
        BeAccounts.update_be_user_password(be_user, "invalid", %{password: valid_be_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{be_user: be_user} do
      {:ok, be_user} =
        BeAccounts.update_be_user_password(be_user, valid_be_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(be_user.password)
      assert BeAccounts.get_be_user_by_email_and_password(be_user.email, "new valid password")
    end

    test "deletes all tokens for the given be_user", %{be_user: be_user} do
      _ = BeAccounts.generate_be_user_session_token(be_user)

      {:ok, _} =
        BeAccounts.update_be_user_password(be_user, valid_be_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end
  end

  describe "generate_be_user_session_token/1" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "generates a token", %{be_user: be_user} do
      token = BeAccounts.generate_be_user_session_token(be_user)
      assert be_user_token = Repo.get_by(BeUserToken, token: token)
      assert be_user_token.context == "session"

      # Creating the same token for another be_user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%BeUserToken{
          token: be_user_token.token,
          be_user_id: be_user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_be_user_by_session_token/1" do
    setup do
      be_user = be_user_fixture()
      token = BeAccounts.generate_be_user_session_token(be_user)
      %{be_user: be_user, token: token}
    end

    test "returns be_user by token", %{be_user: be_user, token: token} do
      assert session_be_user = BeAccounts.get_be_user_by_session_token(token)
      assert session_be_user.id == be_user.id
    end

    test "does not return be_user for invalid token" do
      refute BeAccounts.get_be_user_by_session_token("oops")
    end

    test "does not return be_user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(BeUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute BeAccounts.get_be_user_by_session_token(token)
    end
  end

  describe "delete_be_user_session_token/1" do
    test "deletes the token" do
      be_user = be_user_fixture()
      token = BeAccounts.generate_be_user_session_token(be_user)
      assert BeAccounts.delete_be_user_session_token(token) == :ok
      refute BeAccounts.get_be_user_by_session_token(token)
    end
  end

  describe "deliver_be_user_confirmation_instructions/2" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "sends token through notification", %{be_user: be_user} do
      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_confirmation_instructions(be_user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert be_user_token = Repo.get_by(BeUserToken, token: :crypto.hash(:sha256, token))
      assert be_user_token.be_user_id == be_user.id
      assert be_user_token.sent_to == be_user.email
      assert be_user_token.context == "confirm"
    end
  end

  describe "confirm_be_user/1" do
    setup do
      be_user = be_user_fixture()

      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_confirmation_instructions(be_user, url)
        end)

      %{be_user: be_user, token: token}
    end

    test "confirms the email with a valid token", %{be_user: be_user, token: token} do
      assert {:ok, confirmed_be_user} = BeAccounts.confirm_be_user(token)
      assert confirmed_be_user.confirmed_at
      assert confirmed_be_user.confirmed_at != be_user.confirmed_at
      assert Repo.get!(BeUser, be_user.id).confirmed_at
      refute Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end

    test "does not confirm with invalid token", %{be_user: be_user} do
      assert BeAccounts.confirm_be_user("oops") == :error
      refute Repo.get!(BeUser, be_user.id).confirmed_at
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end

    test "does not confirm email if token expired", %{be_user: be_user, token: token} do
      {1, nil} = Repo.update_all(BeUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert BeAccounts.confirm_be_user(token) == :error
      refute Repo.get!(BeUser, be_user.id).confirmed_at
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end
  end

  describe "deliver_be_user_reset_password_instructions/2" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "sends token through notification", %{be_user: be_user} do
      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_reset_password_instructions(be_user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert be_user_token = Repo.get_by(BeUserToken, token: :crypto.hash(:sha256, token))
      assert be_user_token.be_user_id == be_user.id
      assert be_user_token.sent_to == be_user.email
      assert be_user_token.context == "reset_password"
    end
  end

  describe "get_be_user_by_reset_password_token/1" do
    setup do
      be_user = be_user_fixture()

      token =
        extract_be_user_token(fn url ->
          BeAccounts.deliver_be_user_reset_password_instructions(be_user, url)
        end)

      %{be_user: be_user, token: token}
    end

    test "returns the be_user with valid token", %{be_user: %{id: id}, token: token} do
      assert %BeUser{id: ^id} = BeAccounts.get_be_user_by_reset_password_token(token)
      assert Repo.get_by(BeUserToken, be_user_id: id)
    end

    test "does not return the be_user with invalid token", %{be_user: be_user} do
      refute BeAccounts.get_be_user_by_reset_password_token("oops")
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end

    test "does not return the be_user if token expired", %{be_user: be_user, token: token} do
      {1, nil} = Repo.update_all(BeUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute BeAccounts.get_be_user_by_reset_password_token(token)
      assert Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end
  end

  describe "reset_be_user_password/2" do
    setup do
      %{be_user: be_user_fixture()}
    end

    test "validates password", %{be_user: be_user} do
      {:error, changeset} =
        BeAccounts.reset_be_user_password(be_user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{be_user: be_user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = BeAccounts.reset_be_user_password(be_user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{be_user: be_user} do
      {:ok, updated_be_user} = BeAccounts.reset_be_user_password(be_user, %{password: "new valid password"})
      assert is_nil(updated_be_user.password)
      assert BeAccounts.get_be_user_by_email_and_password(be_user.email, "new valid password")
    end

    test "deletes all tokens for the given be_user", %{be_user: be_user} do
      _ = BeAccounts.generate_be_user_session_token(be_user)
      {:ok, _} = BeAccounts.reset_be_user_password(be_user, %{password: "new valid password"})
      refute Repo.get_by(BeUserToken, be_user_id: be_user.id)
    end
  end

  describe "inspect/2 for the BeUser module" do
    test "does not include password" do
      refute inspect(%BeUser{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
