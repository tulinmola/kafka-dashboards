defmodule Kdb.TopicChannel do
  use Kdb.Web, :channel

  alias Kdb.Topic

  def join("topic:" <> name, payload, socket) do
    if authorized?(payload) do
      response = %{messages: Topic.latest_messages(name)}
      send(self, :after_join)
      {:ok, response, assign(socket, :topic, name)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    name = socket.assigns.topic
    Topic.on_message(name, fn (message) ->
      broadcast socket, "message", message
    end)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
