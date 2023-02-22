defmodule MyApp.BeAccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyApp.BeAccounts` context.
  """

  def unique_be_user_email, do: "be_user#{System.unique_integer()}@example.com"
  def valid_be_user_password, do: "hello world!"

  def valid_be_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_be_user_email(),
      password: valid_be_user_password()
    })
  end

  def be_user_fixture(attrs \\ %{}) do
    {:ok, be_user} =
      attrs
      |> valid_be_user_attributes()
      |> MyApp.BeAccounts.register_be_user()

    be_user
  end

  def extract_be_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
