defmodule Kdb.PageController do
  use Kdb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
