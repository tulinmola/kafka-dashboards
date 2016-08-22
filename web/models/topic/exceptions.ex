defmodule Kdb.Topic.NoResultsError do
  @moduledoc """
  Raised when no topic is found.
  """
  defexception plug_status: 404, message: "no topic found"

  def exception(opts) do
    name = Keyword.fetch!(opts, :topic)

    msg = """
    expected topic to exist:

    #{name}
    """

    %__MODULE__{message: msg}
  end
end
