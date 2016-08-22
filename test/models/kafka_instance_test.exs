defmodule Kdb.KafkaInstanceTest do
  use ExUnit.Case, async: false

  alias Kdb.KafkaInstance

  defp create_worker do
    instance = %KafkaInstance{
      name: "test",
      uris: "192.168.99.100:9092"
    }
    KafkaInstance.create_worker(instance)
  end

  test "should create an instance worker" do
    assert create_worker
  end

  test "valid name" do
    changeset = KafkaInstance.changeset(%KafkaInstance{name: ""})
    assert changeset.errors[:name]
  end

  test "invalid uri format" do
    changeset = KafkaInstance.changeset(%KafkaInstance{}, %{uris: "invalid"})
    assert changeset.errors[:uris]
  end

  test "should create without consumer group" do
    config = KafkaInstance.to_kafka_ex(%KafkaInstance{uris: "192.168.99.100:9092"})
    assert config[:consumer_group] == :no_consumer_group
  end
end
