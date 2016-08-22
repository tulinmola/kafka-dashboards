defmodule Kdb.KafkaHelpers do
  def ensure_topic_exists(topic \\ nil) do
    topic = topic || UUID.uuid4
    KafkaEx.metadata(topic: topic)
    topic
  end

  def produce_and_wait(messages) when is_list(messages) do
    topic = ensure_topic_exists
    # Write messages to this new topic
    Enum.each(messages, &(KafkaEx.produce(topic, 0, &1)))
    # Create a consumer and ensure messages where written
    topic
    |> KafkaEx.stream(0, offset: 0, auto_commit: false)
    |> Enum.take(Enum.count(messages))
    # And return topic name
    topic
  end

  def produce_and_wait(message), do: produce_and_wait([message])

  def produce(topic, partition \\ 0, message) do
    KafkaEx.produce(topic, partition, message)
  end
end
