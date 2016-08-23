defmodule Kdb.TopicChannel do
  use Kdb.Web, :channel

  alias Kdb.{Repo, KafkaInstance, Topic}

  def join("topic:" <> topic, payload, socket) do
    if authorized?(payload) do
      [kafka_instance_id, name] = String.split(topic, ",")

      kafka_instance = Repo.get!(KafkaInstance, kafka_instance_id)
      worker = UUID.uuid4 |> String.to_atom
      {:ok, _pid} = KafkaInstance.worker(kafka_instance, name: worker)   # TODO: reuse workers...
      response = %{messages: Topic.latest_messages(worker, name)}

      send(self, :after_join)

      socket = socket
        |> assign(:topic, name)
        |> assign(:kafka_instance, kafka_instance)
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    kafka_instance = socket.assigns.kafka_instance
    topic = socket.assigns.topic
    Topic.on_message(kafka_instance, topic, fn (message) ->
      broadcast socket, "message", message
    end)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
