defmodule Kdb.KafkaInstanceActionControllerTest do
  use Kdb.ConnCase

  alias Kdb.KafkaInstance

  test "exports to json", %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    conn = get conn, kafka_instance_action_path(conn, :export, kafka_instance)
    response = json_response(conn, 200)
    expected = %{
      "consumer_group" => kafka_instance.consumer_group,
      "has_consumer_group" => kafka_instance.has_consumer_group,
      "id" => kafka_instance.id,
      "kafka_version" => kafka_instance.kafka_version,
      "max_restarts" => kafka_instance.max_restarts,
      "max_seconds" => kafka_instance.max_seconds,
      "name" => kafka_instance.name,
      "sync_timeout" => kafka_instance.sync_timeout,
      "uris" => kafka_instance.uris
    }
    assert response == expected
  end
end
