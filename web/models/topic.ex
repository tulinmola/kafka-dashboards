defmodule Kdb.Topic do
  # @type t :: %Topic{name: binary, partitions: List}
  @derive {Phoenix.Param, key: :name}
  defstruct [name: "", partitions: []]

  alias Kdb.KafkaInstance
  alias Kdb.Topic.NoResultsError

  def all(%KafkaInstance{} = kafka_instance) do
    kafka_instance
    |> ensure_kafka_worker("__all")
    |> all
  end

  @doc """
  Gets all topics from kafka
  """
  def all(worker) do
    KafkaEx.metadata(worker_name: worker).topic_metadatas
    |> Enum.map(&(from_kafka(&1)))
  end

  @doc """
  Gets topic from kafka creating it if doesn't exist
  """
  # @spec by_name(binary) :: t
  def by_name(worker, name) do
    from_kafka(worker, name)
  end

  def by_name!(%KafkaInstance{} = kafka_instance, name) do
    kafka_instance
    |> ensure_kafka_worker(name)
    |> by_name!(name)
  end

  @doc """
  Gets topic from kafka and raises exception if it doesn't exist
  """
  def by_name!(worker, name) do
    topic = worker
      |> all
      |> Enum.find(&(&1.name == name))
    case topic do
      nil -> raise NoResultsError, [topic: name]
      _ -> topic
    end
  end

  def latest_offset(worker, name) do
    latest_offset(KafkaEx.latest_offset(name, 0, worker))
  end
  def latest_offset([%KafkaEx.Protocol.Offset.Response{
                        partition_offsets: [%{offset: [offset]}]}]) do
    offset
  end

  def earliest_offset(worker, name) do
    earliest_offset(KafkaEx.earliest_offset(name, 0, worker))
  end
  def earliest_offset([%KafkaEx.Protocol.Offset.Response{
                          partition_offsets: [%{offset: [offset]}]}]) do
    offset
  end

  def latest_messages(worker, name, count \\ 10) do
    offset = max(latest_offset(worker, name) - count, earliest_offset(worker, name))
    [%KafkaEx.Protocol.Fetch.Response{partitions: [%{message_set: messages}]}] =
      KafkaEx.fetch(name, 0, offset: offset, auto_commit: false, worker_name: worker)
    Enum.map(messages, &(&1.value))
  end

  def on_message(kafka_instance, name, callback) do
    worker = ensure_kafka_worker(kafka_instance, name)
    offset = latest_offset(worker, name)
    spawn_link fn ->
      name
      |> KafkaEx.stream(0, offset: offset, worker_name: worker, auto_commit: false)
      |> Enum.each(&(callback.(from_kafka(&1))))
    end
  end

  defp ensure_kafka_worker(%KafkaInstance{} = kafka_instance, name) do
    worker_name = String.to_atom("instances/#{kafka_instance.id}/topics/#{name}")
    config = KafkaInstance.to_kafka_ex(kafka_instance)
    ensure_kafka_worker(worker_name, config)
    worker_name
  end

  defp ensure_kafka_worker(name, config) do
    # TODO: Maybe looking for process with name instead of recreating worker?
    case KafkaEx.create_worker(name, config) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      result -> result
    end
  end

  defp from_kafka(worker, name) when is_binary(name) do
    # Note that this could create a topic if it doesn't exist
    from_kafka(KafkaEx.metadata(topic: name, worker_name: worker))
  end
  defp from_kafka(%KafkaEx.Protocol.Metadata.Response{topic_metadatas: [topic]}) do
    from_kafka(topic)
  end
  defp from_kafka(%KafkaEx.Protocol.Metadata.TopicMetadata{topic: name}) do
    %__MODULE__{name: name}
  end
  defp from_kafka(%KafkaEx.Protocol.Fetch.Message{offset: offset, value: value}) do
    %{offset: offset, value: value}
  end
end
