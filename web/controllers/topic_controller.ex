defmodule Kdb.TopicController do
  use Kdb.Web, :controller

  alias Kdb.{Topic, KafkaInstance}

  plug :get_kafka_instance

  def index(conn, _params) do
    kafka_instance = conn.assigns.kafka_instance
    topics = Topic.all(kafka_instance)
    render(conn, "index.html", topics: topics)
  end

  def show(conn, %{"id" => name}) do
    kafka_instance = conn.assigns.kafka_instance
    topic = Topic.by_name!(kafka_instance, name)
    render(conn, "show.html", topic: topic)
  end

  defp get_kafka_instance(conn, _) do
    %{"kafka_instance_id" => id} = conn.params
    kafka_instance = Repo.get!(KafkaInstance, id)
    assign(conn, :kafka_instance, kafka_instance)
  end
end
