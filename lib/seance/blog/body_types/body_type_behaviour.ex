defmodule Seance.Blog.BodyTypeBehaviour do
  @callback from_node(type :: String.t()) :: Struct.t()
  @callback to_node(map()) :: map()
end
