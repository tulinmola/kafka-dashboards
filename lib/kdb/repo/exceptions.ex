defmodule Kdb.Repo.NoResultsError do
  @moduledoc """
  Raised when no result is found in repo.
  """
  defexception plug_status: 404, message: "no results found"

  def exception(opts) do
    id = Keyword.fetch!(opts, :id)

    msg = """
    couldn't find model by id

    #{id}
    """

    %__MODULE__{message: msg}
  end
end
