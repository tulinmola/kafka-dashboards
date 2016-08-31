defmodule Kdb.KafkaInstanceControllerTest do
  use Kdb.ConnCase

  alias Kdb.KafkaInstance

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, kafka_instance_path(conn, :index)
    html = html_response(conn, 200)

    assert_inner_text(html, "h2", "Kafka instances")
    assert_element_exists(html, "ul.kafka-instances")
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, kafka_instance_path(conn, :new)
    html = html_response(conn, 200)

    assert_title_with_index_link(html, "New")
    assert_element_exists(html, "form")
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    name = "creation test"
    params = build(:kafka_instance, name: name) |> Map.from_struct
    conn = post conn, kafka_instance_path(conn, :create), kafka_instance: params

    assert redirected_to(conn) == kafka_instance_path(conn, :index)
    assert Repo.get_by(KafkaInstance, %{name: name})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    params = params_for(:kafka_instance, %{name: nil})
    conn = post conn, kafka_instance_path(conn, :create), kafka_instance: params
    html = html_response(conn, 200)

    assert_title_with_index_link(html, "New")
    assert_element_exists(html, "form")
  end

  test "shows chosen resource", %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    conn = get conn, kafka_instance_path(conn, :show, kafka_instance)
    html = html_response(conn, 200)

    assert_title_with_index_link(html, kafka_instance.name)
    assert_element_exists(html, ".topics")
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, kafka_instance_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    conn = get conn, kafka_instance_path(conn, :edit, kafka_instance)
    html = html_response(conn, 200)

    assert_title_with_index_link(html, "Edit")
    assert_element_exists(html, "form")
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    params = %{name: "changed"}
    conn = put conn, kafka_instance_path(conn, :update, kafka_instance), kafka_instance: params

    assert redirected_to(conn) == kafka_instance_path(conn, :show, kafka_instance)
    assert Repo.get_by(KafkaInstance, params)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    params = %{name: nil}
    conn = put conn, kafka_instance_path(conn, :update, kafka_instance), kafka_instance: params
    html = html_response(conn, 200)

    assert_title_with_index_link(html, "Edit")
    assert_element_exists(html, "form")
  end

  test "deletes chosen resource", %{conn: conn} do
    kafka_instance = insert(:kafka_instance)
    conn = delete conn, kafka_instance_path(conn, :delete, kafka_instance)
    assert redirected_to(conn) == kafka_instance_path(conn, :index)
    refute Repo.get(KafkaInstance, kafka_instance.id)
  end

  defp assert_title_with_index_link(html, title) do
    assert_inner_text(html, "h2", title, contains: true)
    assert_element_exists(html, "h2 a", "Kafka instances",
                          href: kafka_instance_path(build_conn, :index))
  end
end
