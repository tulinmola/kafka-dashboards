defmodule Kdb.KafkaInstanceActionController do
  use Kdb.Web, :controller

  alias Kdb.KafkaInstance

  def export(conn, %{"kafka_instance_id" => id}) do
    kafka_instance = Repo.get!(KafkaInstance, id)
    conn
    |> put_resp_content_type("application/json")
    |> render("kafka_instance.json", kafka_instance: kafka_instance)
  end
end
