defmodule Kdb.TopicView do
  use Kdb.Web, :view

  def channel_name(kafka_instance, topic) do
    "#{kafka_instance.id},#{topic.name}"
  end
end
