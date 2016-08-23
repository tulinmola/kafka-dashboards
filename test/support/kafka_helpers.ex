defmodule Kdb.KafkaHelpers do
  alias Kdb.KafkaInstance

  def ensure_topic_exists(worker_or_kafka_instance), do:
    ensure_topic_exists(worker_or_kafka_instance, nil)

  def ensure_topic_exists(%KafkaInstance{} = kafka_instance, topic) do
    worker = UUID.uuid4 |> String.to_atom
    {:ok, _pid} = KafkaInstance.worker(kafka_instance, name: worker)
    ensure_topic_exists(worker, topic)
  end

  def ensure_topic_exists(worker, topic) do
    topic = topic || UUID.uuid4
    KafkaEx.metadata(topic: topic, worker_name: worker)
    topic
  end

  def produce_and_wait(worker, messages) when is_list(messages) do
    topic = ensure_topic_exists(worker)
    # Write messages to this new topic
    Enum.each(messages, &(KafkaEx.produce(topic, 0, &1, worker_name: worker)))
    # Create a consumer and ensure messages where written
    topic
    |> KafkaEx.stream(0, offset: 0, auto_commit: false, worker_name: worker)
    |> Enum.take(Enum.count(messages))
    # And return topic name
    topic
  end
  def produce_and_wait(worker, message), do: produce_and_wait(worker, [message])

  def produce(worker, topic, partition \\ 0, message) do
    KafkaEx.produce(topic, partition, message, worker_name: worker)
  end
end
