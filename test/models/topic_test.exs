defmodule Kdb.TopicTest do
  use ExUnit.Case, async: false
  import Kdb.KafkaHelpers

  alias Kdb.Topic

  test "should get all topics" do
    first = produce_and_wait("a")
    second = produce_and_wait("b")
    topics = Topic.all
    assert Enum.find(topics, &(&1.name == first))
    assert Enum.find(topics, &(&1.name == second))
  end

  test "should create topic when doesn't exist" do
    name = UUID.uuid4
    assert %Topic{name: ^name} = Topic.by_name(name)
  end

  test "should get latest offset" do
    messages = ~w(first second third)
    topic = produce_and_wait(messages)
    assert Topic.latest_offset(topic) == 3
  end

  test "should get latest messages" do
    messages = ~w(first second third)
    topic = produce_and_wait(messages)
    assert Topic.latest_messages(topic, 2) == Enum.slice(messages, 1, 2)
  end

  test "should callback on message" do
    topic = ensure_topic_exists
    value = "test message"
    parent = self
    Topic.on_message(topic, fn (message) ->
      assert message == %{offset: 0, value: value}
      send parent, :on_message
    end)
    produce(topic, value)
    assert_receive :on_message, 1000
  end
end
