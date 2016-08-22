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

defmodule Kdb.Repo.InvalidChangesetError do
  @moduledoc """
  Raised when we cannot perform an action because the
  changeset is invalid.
  """
  defexception [:action, :changeset]

  def message(%{action: action, changeset: changeset}) do
    """
    could not perform #{action} because changeset is invalid.
    * Changeset changes
    #{inspect changeset.changes}
    * Changeset params
    #{inspect changeset.params}
    * Changeset errors
    #{inspect changeset.errors}
    """
  end
end
