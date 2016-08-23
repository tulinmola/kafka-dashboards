defmodule Kdb.TopicTest do
  use ExUnit.Case, async: false
  import Kdb.KafkaHelpers
  import Kdb.Factory, only: [build: 1]

  alias Kdb.{KafkaInstance, Topic}

  @moduletag timeout: 5000

  setup do
    kafka_instance = build(:kafka_instance)
    worker = UUID.uuid4 |> String.to_atom
    {:ok, _pid} = KafkaInstance.worker(kafka_instance, name: worker)

    {:ok, worker: worker, kafka_instance: kafka_instance}
  end

  test "should get all topics from kafka instance",
       %{worker: worker, kafka_instance: kafka_instance} do
    first = produce_and_wait(worker, "a")
    second = produce_and_wait(worker, "b")
    topics = Topic.all(kafka_instance)
    assert Enum.find(topics, &(&1.name == first))
    assert Enum.find(topics, &(&1.name == second))
  end

  test "should get all topics from worker", %{worker: worker} do
    first = produce_and_wait(worker, "a")
    second = produce_and_wait(worker, "b")
    topics = Topic.all(worker)
    assert Enum.find(topics, &(&1.name == first))
    assert Enum.find(topics, &(&1.name == second))
  end

  test "should get topic with bang by name", %{worker: worker} do
    topic = ensure_topic_exists(worker)
    assert %Topic{name: ^topic} = Topic.by_name!(worker, topic)
  end

  test "should raise error when getting inexistent topic with bang",
       %{worker: worker} do
    assert_raise Topic.NoResultsError, fn ->
      Topic.by_name!(worker, "non-existent-topic")
    end
  end

  test "should create topic when doesn't exist", %{worker: worker} do
    name = UUID.uuid4
    assert %Topic{name: ^name} = Topic.by_name(worker, name)
  end

  test "should get latest offset", %{worker: worker} do
    messages = ~w(first second third)
    topic = produce_and_wait(worker, messages)
    assert Topic.latest_offset(worker, topic) == 3
  end

  test "should get latest messages", %{worker: worker} do
    messages = ~w(first second third)
    topic = produce_and_wait(worker, messages)
    assert Topic.latest_messages(worker, topic, 2) == Enum.slice(messages, 1, 2)
  end

  test "should callback on message", %{worker: worker, kafka_instance: kafka_instance} do
    topic = ensure_topic_exists(worker)
    value = "test message"
    parent = self
    Topic.on_message(kafka_instance, topic, fn (message) ->
      assert message == %{offset: 0, value: value}
      send parent, :on_message
    end)
    produce(worker, topic, value)
    assert_receive :on_message, 1000
  end
end
