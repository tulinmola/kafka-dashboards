defmodule Kdb.KafkaInstanceActionView do
  use Kdb.Web, :view

  def render("kafka_instance.json", %{kafka_instance: kafka_instance}) do
    kafka_instance
  end
end
