defmodule MyApp.Ashtags do
  import MyApp.Utils.MyGuards

  alias MyApp.Api
  alias MyApp.Ashtags.Tag

  def get_tag_by_uuid_or_slug(%Tag{} = tag), do: tag

  def get_tag_by_uuid_or_slug(uuid) when is_uuid(uuid) do
    Api.get(Tag, uuid)
    |> case do
      {:ok, tag} -> tag
      _ -> nil
    end
  end

  def get_tag_by_uuid_or_slug(slug) when is_binary(slug) do
    Api.get(Tag, slug: slug)
    |> case do
      {:ok, tag} -> tag
      _ -> nil
    end
  end

  def get_tag_by_uuid_or_slug(_), do: nil

  def handle_tags_on_entities(
        type_str,
        entity_ids,
        tag_ids,
        api,
        resource,
        relationship_name \\ :tags
      )
      when type_str in ["add", "remove"] and is_list(entity_ids) and is_list(tag_ids) and
             is_atom(api) and
             is_atom(resource) do
    # "Ashtags.handle_tags_on_entities(\"#{type_str}\", #{entity_ids |> inspect()}, #{tag_ids |> inspect()}, #{api}, #{resource},\"#{relationship_name})\""
    # |> IO.puts()
    # |> MavuUtils.log(" clred ", :info)

    for entity_id <- entity_ids do
      api.get(resource, entity_id, load: [relationship_name])
      |> case do
        {:ok, entity} ->
          handle_tags_on_entity(type_str, entity, tag_ids, api, resource, relationship_name)

        _ ->
          {:error, entity_id}
      end
    end
  end

  def handle_tags_on_entity(type_str, entity, tag_ids, api, resource, relationship_name \\ :tags)
      when type_str in ["add", "remove"] and is_map(entity) and is_list(tag_ids) and is_atom(api) and
             is_atom(resource) do
    opts =
      case type_str do
        "add" -> [type: :append]
        "remove" -> [on_match: :unrelate]
      end

    entity
    |> Ash.Changeset.for_update(:update)
    |> Ash.Changeset.manage_relationship(relationship_name, tag_ids, opts)
    |> api.update!()
  end

  # MyApp.Stockchanges.Stockchange
  # |> Ash.Changeset.for_create(:create, %{note: "frucade", amount: "20.3"})
  # |> Ash.Changeset.replace_relationship(:product, 25)
  # |> MyApp.Stockchanges.create!()
end
