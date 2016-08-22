defmodule Kdb.KafkaInstanceController do
  use Kdb.Web, :controller

  alias Kdb.{Repo, KafkaInstance}

  def index(conn, _params) do
    kafka_instances = Repo.all(KafkaInstance)
    render(conn, "index.html", kafka_instances: kafka_instances)
  end

  def new(conn, _params) do
    changeset = KafkaInstance.changeset(%KafkaInstance{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"kafka_instance" => kafka_instance_params}) do
    changeset = KafkaInstance.changeset(%KafkaInstance{}, kafka_instance_params)

    case Repo.insert(changeset) do
      {:ok, _kafka_instance} ->
        conn
        |> put_flash(:info, "Kafka instance created successfully.")
        |> redirect(to: kafka_instance_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    kafka_instance = Repo.get!(KafkaInstance, id)
    render(conn, "show.html", kafka_instance: kafka_instance)
  end

  def edit(conn, %{"id" => id}) do
    kafka_instance = Repo.get!(KafkaInstance, id)
    changeset = KafkaInstance.changeset(kafka_instance)
    render(conn, "edit.html", kafka_instance: kafka_instance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "kafka_instance" => kafka_instance_params}) do
    kafka_instance = Repo.get!(KafkaInstance, id)
    changeset = KafkaInstance.changeset(kafka_instance, kafka_instance_params)

    case Repo.update(changeset) do
      {:ok, kafka_instance} ->
        conn
        |> put_flash(:info, "Kafka instance updated successfully.")
        |> redirect(to: kafka_instance_path(conn, :show, kafka_instance))
      {:error, changeset} ->
        render(conn, "edit.html", kafka_instance: kafka_instance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    kafka_instance = Repo.get!(KafkaInstance, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(kafka_instance)

    conn
    |> put_flash(:info, "Kafka instance deleted successfully.")
    |> redirect(to: kafka_instance_path(conn, :index))
  end
end
