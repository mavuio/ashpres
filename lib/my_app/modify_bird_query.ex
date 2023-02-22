defmodule MyApp.ModifyBirdQuery do
  def modify(_ash_query, data_layer_query) do
    data_layer_query |> MavuUtils.log("INFO clblue", :info)
    {:ok, data_layer_query}
  end
end
