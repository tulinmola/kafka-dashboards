defmodule Kdb.LayoutView do
  use Kdb.Web, :view

  def current_controller(view_module) do
    view_module
    |> Atom.to_string
    |> String.split(".")
    |> Enum.at(-1)
  end
end
