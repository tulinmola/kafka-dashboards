defmodule Kdb.Topic do
  # @type t :: %Topic{name: binary, partitions: List}
  @derive {Phoenix.Param, key: :name}
  defstruct [name: "", partitions: []]

  alias Kdb.Topic.NoResultsError

  @doc """
  Gets all topics from kafka
  """
  def all do
    KafkaEx.metadata.topic_metadatas
    |> Enum.map(&(from_kafka(&1)))
  end

  @doc """
  Gets topic from kafka creating it if doesn't exist
  """
  # @spec by_name(binary) :: t
  def by_name(name) when is_binary(name) do
    from_kafka(name)
  end

  @doc """
  Gets topic from kafka and raises exception if it doesn't exist
  """
  def by_name!(name) do
    topic = all |> Enum.find(&(&1.name == name))
    case topic do
      nil -> raise NoResultsError, [topic: name]
      _ -> topic
    end
  end

  def latest_offset(name) when is_binary(name) do
    latest_offset(KafkaEx.latest_offset(name, 0))
  end
  def latest_offset([%KafkaEx.Protocol.Offset.Response{partition_offsets: [%{offset: [offset]}]}]) do
    offset
  end

  def earliest_offset(name) when is_binary(name) do
    earliest_offset(KafkaEx.earliest_offset(name, 0))
  end
  def earliest_offset([%KafkaEx.Protocol.Offset.Response{partition_offsets: [%{offset: [offset]}]}]) do
    offset
  end

  def latest_messages(name, count \\ 10) do
    offset = max(latest_offset(name) - count, earliest_offset(name))
    [%KafkaEx.Protocol.Fetch.Response{partitions: [%{message_set: messages}]}] =
      KafkaEx.fetch(name, 0, offset: offset, auto_commit: false)
    Enum.map(messages, &(&1.value))
  end

  def on_message(name, callback) do
    offset = latest_offset(name)
    worker_name = String.to_atom("topic:#{name}")
    {:ok, _pid} = ensure_kafka_worker(worker_name)
    spawn_link fn ->
      KafkaEx.stream(name, 0, offset: offset, worker_name: worker_name, auto_commit: false)
      |> Enum.each(&(callback.(from_kafka(&1))))
    end
  end

  defp ensure_kafka_worker(name) do
    # TODO: Maybe looking for process with name instead of recreating worker?
    case KafkaEx.create_worker(name) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      result -> result
    end
  end

  defp from_kafka(name) when is_binary(name) do
    # Note that this could create a topic if it doesn't exist
    from_kafka(KafkaEx.metadata(topic: name))
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
