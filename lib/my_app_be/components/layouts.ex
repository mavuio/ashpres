defmodule MyAppBe.Layouts do
  use MyAppBe, :html

  def get_target_current_paths(%{current_url: current_url}, args) when is_binary(current_url) do
    target_path =
      cond do
        is_binary(args[:navigate]) -> args[:navigate]
        is_binary(args[:patch]) -> args[:patch]
        is_binary(args[:href]) -> args[:href]
        true -> "__nomatch__"
      end
      |> URI.parse()
      |> Map.get(:path)
      |> String.trim()

    current_path =
      current_url
      |> URI.parse()
      |> Map.get(:path)
      |> String.trim()

    {target_path, current_path}
  end

  def get_target_current_paths(_context, _args), do: {"_nomatch_", "_nevermatch_"}

  def link_is_active?(context, args) do
    {target_path, current_path} = get_target_current_paths(context, args)

    active? =
      case args[:path_compare] do
        :strict -> target_path == current_path
        _ -> String.starts_with?(current_path, target_path)
      end

    if active? and args[:url_contains] do
      String.contains?(context.current_url, args[:url_contains])
    else
      active?
    end
  end

  def append_link_classes(args, context, link_class) do
    args ++ [class: [link_class, if(link_is_active?(context, args), do: "is-active", else: "")]]
  end

  embed_templates "layouts/*"
end
