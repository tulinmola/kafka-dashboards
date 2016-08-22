defmodule Kdb.Repo do
  @initial_state %{}
  @default_opts [repo: __MODULE__]

  def start_link(opts \\ [name: __MODULE__]) do
    Agent.start_link(fn -> @initial_state end, name: opts[:name])
  end

  def all(module, opts \\ @default_opts) do
    Agent.get(opts[:repo], fn state ->
      state[state_key(module)] || []
    end)
  end

  defp state_key(%Ecto.Changeset{} = changeset) do
    state_key(changeset.data.__struct__)
  end
  defp state_key(module) do
    module
    |> Atom.to_string
    |> String.split(".")
    |> Enum.at(-1)
  end

  def insert(changeset, opts \\ @default_opts) do
    if changeset.valid? do
      # Get the modified model struct out of the changeset
      model = changeset
        |> Ecto.Changeset.apply_changes
        |> Map.put(:id, UUID.uuid4)

      # Update state
      Agent.update(opts[:repo], fn state ->
        Map.update(state, state_key(changeset), [model], fn collection ->
          List.insert_at(collection, -1, model)
        end)
      end)

      {:ok, model}
    else
      # Annotate the action we tried to perform so the UI shows errors
      changeset = %{changeset | action: :create}
      {:error, changeset}
    end
  end

  def insert!(changeset, opts \\ @default_opts) do
    case insert(changeset, opts) do
      {:ok, model} -> model
      _ -> raise "Couldn't insert changeset"
    end
  end

  def update(changeset, opts \\ @default_opts) do
    if changeset.valid? do
      # Get the modified model struct out of the changeset
      model = Ecto.Changeset.apply_changes(changeset)
      id = model.id

      case get(model.__struct__, id, opts) do
        nil ->
          {:error, :not_found}
        _ ->
          Agent.update(opts[:repo], fn state ->
            Map.update(state, state_key(changeset), [], fn collection ->
              index = Enum.find_index(collection, &(&1.id == id))
              List.update_at(collection, index, fn _ -> model end)
            end)
          end)
          {:ok, model}
      end
    else
      # Annotate the action we tried to perform so the UI shows errors
      changeset = %{changeset | action: :update}
      {:error, changeset}
    end
  end

  def delete(model, opts \\ @default_opts) do
    module = model.__struct__
    id = model.id
    case get(module, id, opts) do
      nil ->
        {:error, :not_found}
      _ ->
        Agent.update(opts[:repo], fn state ->
          Map.update(state, state_key(module), [], fn collection ->
            Enum.reject(collection, &(&1.id == id))
          end)
        end)
        {:ok, model}
    end
  end

  def delete!(model, opts \\ @default_opts) do
    case get(model.__struct__, model.id, opts) do
      nil -> raise "Not found: #{model.id}"
      model ->
        {:ok, _model} = delete(model, opts)
        model
    end
  end

  def get(module, id, opts \\ @default_opts) do
    key = state_key(module)
    Agent.get(opts[:repo], fn state ->
      Enum.find(state[key] || [], &(&1.id == id))
    end)
  end

  def get!(module, id, opts \\ @default_opts) do
    case get(module, id, opts) do
      nil -> raise "Not found: #{id}"
      model -> model
    end
  end

  def get_by(module, fields, opts \\ @default_opts) do
    key = state_key(module)
    Agent.get(opts[:repo], fn state ->
      Enum.find(state[key] || [], &(&1 = fields))
    end)
  end
end
