defmodule Kdb.KafkaInstance do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :uris, :string, default: ""
    field :has_consumer_group, :boolean, default: :false
    field :consumer_group, :string
    field :sync_timeout, :integer, default: 3000
    field :max_restarts, :integer, default: 10
    field :max_seconds, :integer, default: 60
    field :kafka_version, :string, default: "0.8.2.1"
  end

  @fields ~w(name uris has_consumer_group consumer_group sync_timeout
             max_restarts max_seconds kafka_version)a
  @required_fields ~w(name uris has_consumer_group sync_timeout max_restarts
                      max_seconds kafka_version)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_consumer_group
    |> validate_uris
  end

  defp validate_consumer_group(changeset) do
    if get_field(changeset, :has_consumer_group) do
      validate_required(changeset, :consumer_group)
    else
      changeset
    end
  end

  defp validate_uris(%Ecto.Changeset{} = changeset) do
    validate_uris(changeset, get_field(changeset, :uris))
  end
  defp validate_uris(changeset, nil), do: changeset
  defp validate_uris(changeset, uris) do
    uris
    |> String.split(",")
    |> Enum.reduce(changeset, &validate_uri/2)
  end

  defp validate_uri(uri, changeset) do
    with [_host, string_port] <- String.split(uri, ":"),
         # TODO: validate host format
         {_port, _more} <- Integer.parse(string_port) do
           changeset
         else
           _ -> add_error(changeset, :uris, "not valid uri: {uri}", uri: uri)
         end
  end

  def uris(%Ecto.Changeset{} = model) do
    model
    |> get_field(:uris, "")
    |> uris
  end
  def uris(%__MODULE__{} = model) do
    model.uris
    |> uris
  end
  def uris(string) when is_binary(string) do
    string
    |> String.split(",")
    |> Enum.map(&parse_uri/1)
  end
  defp parse_uri(uri) do
    [host, port_string] = String.split(uri, ":")
    {port, _} = Integer.parse(port_string)
    {host, port}
  end

  def to_kafka_ex(model) do
    model
    |> Map.from_struct
    |> Keyword.new
    |> Keyword.update!(:consumer_group, &kafka_ex_consumer_group/1)
    |> Keyword.update!(:uris, &uris/1)
  end
  defp kafka_ex_consumer_group(keyword) do
    if keyword[:has_consumer_group] do
      keyword[:consumer_group]
    else
      :no_consumer_group
    end
  end

  def create_worker(instance) do
    name = UUID.uuid4 |> String.to_atom
    config = to_kafka_ex(instance)
    {:ok, _pid} = KafkaEx.create_worker(name, config)
    name
  end
end
