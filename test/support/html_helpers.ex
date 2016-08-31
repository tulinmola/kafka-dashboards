defmodule Kdb.HtmlHelpers do
  import ExUnit.Assertions

  def assert_inner_text(html, selector, text, opts \\ []) do
    content = html |> Floki.find(selector) |> Floki.text
    if opts[:contains] do
      assert content =~ text
    else
      assert text == content
    end
  end

  def assert_element_exists(html, selector) do
    refute html |> Floki.find(selector) |> Enum.empty?
  end

  def assert_element_exists(html, selector, text \\ nil, attributes) do
    element = html
      |> Floki.find(selector)
      |> Enum.find(&(has_all_attributes?(&1, attributes)))
    assert element
    if text, do: assert text == Floki.text(element)
  end

  defp has_all_attributes?(element, attributes) do
    Enum.all?(attributes, fn ({key, value}) ->
      [value] == Floki.attribute(element, Atom.to_string(key))
    end)
  end

  def assert_link_exists(html, text \\ nil, path) do
    assert_element_exists(html, "a", text, href: path)
  end
end
