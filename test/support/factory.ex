defmodule Kdb.Factory do
  use ExMachina.Ecto, repo: Kdb.Repo

  def kafka_instance_factory do
    %Kdb.KafkaInstance{
      name: "instance",
      uris: "192.168.100.99:9092",
      has_consumer_group: false,
      # consumer_group: :no_consumer_group,
      sync_timeout: 3000,
      max_restarts: 10,
      max_seconds: 60,
      kafka_version: "0.8.2.1"
    }
  end
end
