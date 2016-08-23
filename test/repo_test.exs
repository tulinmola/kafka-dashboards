defmodule Kdb.RepoTest do
  use ExUnit.Case, async: false

  alias Kdb.Repo

  defmodule Model do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :name, :string
    end

    @fields ~w(name)a

    def changeset(model, params \\ %{}) do
      model
      |> cast(params, @fields)
      |> validate_required(@fields)
    end
  end

  setup do
    {:ok, repo} = Repo.start_link(name: String.to_atom(UUID.uuid4))
    {:ok, repo: repo}
  end

  @valid_params %{name: "model"}
  @invalid_params %{name: nil}

  test "should be empty", %{repo: repo} do
    assert Repo.all(Model, repo: repo) == []
  end

  test "should insert element with id", %{repo: repo} do
    changeset = Model.changeset(%Model{}, @valid_params)
    {:ok, model} = Repo.insert(changeset, repo: repo)

    assert model.id
    assert model.name == Ecto.Changeset.get_field(changeset, :name)
    assert Repo.all(Model, repo: repo) == [model]
  end

  test "should raise an exception inserting an non-valid changeset", %{repo: repo} do
    changeset = Model.changeset(%Model{}, @invalid_params)
    assert_raise Repo.InvalidChangesetError, fn ->
      Repo.insert!(changeset, repo: repo)
    end
  end

  test "should get an element by id", %{repo: repo} do
    changeset = Model.changeset(%Model{}, @valid_params)
    {:ok, model} = Repo.insert(changeset, repo: repo)

    assert Repo.get(Model, model.id, repo: repo) == model
  end

  test "shouln't get an non-existent element", %{repo: repo} do
    result = Repo.get(Model, -1, repo: repo)
    assert !result
  end

  test "should get an element by fields", %{repo: repo} do
    other = UUID.uuid4
    other_changeset = Model.changeset(%Model{}, %{name: other})
    {:ok, _other_model} = Repo.insert(other_changeset, repo: repo)

    name = UUID.uuid4
    model_changeset = Model.changeset(%Model{}, %{name: name})
    {:ok, model} = Repo.insert(model_changeset, repo: repo)

    assert Repo.get_by(Model, %{name: name}, repo: repo) == model
  end

  test "should raise an exception getting an non-existent element", %{repo: repo} do
    assert_raise Repo.NoResultsError, fn ->
      Repo.get!(Model, -1, repo: repo)
    end
  end

  test "should update element", %{repo: repo} do
    changeset = Model.changeset(%Model{}, @valid_params)
    {:ok, model} = Repo.insert(changeset, repo: repo)

    updated_changeset = Model.changeset(model, %{name: "updated"})
    {:ok, updated_model} = Repo.update(updated_changeset, repo: repo)

    assert updated_model.name == "updated"
  end

  test "should delete element", %{repo: repo} do
    changeset = Model.changeset(%Model{}, @valid_params)
    {:ok, model} = Repo.insert(changeset, repo: repo)

    {:ok, _deleted_model} = Repo.delete(model, repo: repo)
    refute Repo.get(Model, model.id, repo: repo)
  end

  test "should raise an exception deleting an non-existent element", %{repo: repo} do
    changeset = Model.changeset(%Model{}, @valid_params)
    model = Ecto.Changeset.apply_changes(changeset)

    assert_raise Repo.NoResultsError, fn ->
      Repo.delete!(model, repo: repo)
    end
  end
end
