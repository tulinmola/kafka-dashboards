defmodule Kdb.TopicChannelTest do
  use Kdb.ChannelCase
  import Kdb.KafkaHelpers
  import Kdb.MyMachina, only: [insert: 1]

  alias Kdb.{KafkaInstance, TopicChannel}

  defp join(messages \\ []) do
    kafka_instance = insert(:kafka_instance)
    worker = UUID.uuid4 |> String.to_atom
    {:ok, _pid} = KafkaInstance.worker(kafka_instance, name: worker)

    topic = produce_and_wait(worker, messages)

    {:ok, reply, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(TopicChannel, "topic:#{kafka_instance.id},#{topic}")

    {:ok, reply, socket, worker, topic}
  end

  test "join replies with first messages" do
    messages = ~w(first second third)
    {:ok, reply, _socket, _worker, _topic} = join(messages)
    assert reply.messages == messages
  end

  test "should broadcasts message when new message arrives" do
    {:ok, _reply, _socket, worker, topic} = join
    message = "new message"
    produce(worker, topic, message)
    assert_broadcast "message", %{offset: 0, value: ^message}
  end
end
