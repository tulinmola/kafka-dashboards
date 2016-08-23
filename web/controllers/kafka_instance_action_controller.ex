defmodule Kdb.KafkaInstanceActionController do
  use Kdb.Web, :controller

  alias Kdb.KafkaInstance

  def export(conn, %{"kafka_instance_id" => id}) do
    kafka_instance = Repo.get!(KafkaInstance, id)
    conn
    |> put_resp_content_type("application/json")
    |> render("kafka_instance.json", kafka_instance: kafka_instance)
  end

  def import(conn, %{"import_params" => import_params}) do
    file = import_params["file"]
    kafka_instance_params = file.path
      |> File.read!
      |> Poison.decode!
    changeset = KafkaInstance.changeset(%KafkaInstance{}, kafka_instance_params)

    case Repo.insert(changeset) do
      {:ok, kafka_instance} ->
        conn
        |> put_flash(:info, "Kafka instance created successfully.")
        |> redirect(to: kafka_instance_path(conn, :show, kafka_instance))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "There were errors with import: #{inspect changeset.errors}")
        |> redirect(to: kafka_instance_path(conn, :index))
    end
  end
end
