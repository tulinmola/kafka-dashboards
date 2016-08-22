defmodule Kdb.MyMachina do
  @doc """
  This module is built over ex_machina to support its functions without using
  an ecto adapter.
  """
  import Kdb.Factory, only: [build: 2]

  alias Kdb.Repo

  def params_for(model, params \\ %{}) do
    model
    |> build(params)
    |> Map.from_struct
  end

  def insert(model, params \\ %{}) do
    instance = build(model, params)
    changeset = instance.__struct__.changeset(instance)
    Repo.insert!(changeset)
  end
end
