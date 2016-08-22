defmodule Kdb.TopicChannelTest do
  use Kdb.ChannelCase
  import Kdb.KafkaHelpers

  alias Kdb.TopicChannel

  defp join(messages \\ []) do
    topic = produce_and_wait(messages)

    {:ok, reply, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(TopicChannel, "topic:#{topic}")

    {:ok, reply, socket, topic}
  end

  test "join replies with first messages" do
    messages = ~w(first second third)
    {:ok, reply, _socket, _topic} = join(messages)
    assert reply.messages == messages
  end

  test "should broadcasts message when new message arrives" do
    {:ok, _reply, _socket, topic} = join
    message = "new message"
    produce(topic, message)
    assert_broadcast "message", %{offset: 0, value: ^message}
  end
end
