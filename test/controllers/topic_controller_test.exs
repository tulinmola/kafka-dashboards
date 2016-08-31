defmodule Kdb.TopicControllerTest do
  use Kdb.ConnCase
  import Kdb.KafkaHelpers

  alias Kdb.Topic

  setup %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    {:ok, conn: conn, kafka_instance: kafka_instance}
  end

  test "lists all entries on index", %{conn: conn, kafka_instance: kafka_instance} do
    conn = get conn, kafka_instance_topic_path(conn, :index, kafka_instance)
    assert html_response(conn, 200) =~ "Listing topics"
  end

  test "shows chosen resource", %{conn: conn, kafka_instance: kafka_instance} do
    name = ensure_topic_exists(kafka_instance, "test")
    topic = %Topic{name: name}
    conn = get conn, kafka_instance_topic_path(conn, :show, kafka_instance, topic)
    html = html_response(conn, 200)

    assert_title_with_index_link(html, kafka_instance, topic.name)
  end

  test "renders page not found when id is nonexistent",
       %{conn: conn, kafka_instance: kafka_instance} do
    assert_error_sent 404, fn ->
      get conn, kafka_instance_topic_path(conn, :show, kafka_instance, -1)
    end
  end

  defp assert_title_with_index_link(html, kafka_instance, topic) do
    assert_inner_text(html, "h2", topic, contains: true)
    assert_element_exists(html, "h2 a", "Kafka instances",
                          href: kafka_instance_path(build_conn, :index))
    assert_element_exists(html, "h2 a", kafka_instance.name,
                          href: kafka_instance_path(build_conn, :show, kafka_instance))
  end
end
