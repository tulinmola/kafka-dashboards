import "phoenix_html"
import socket from "./socket"
import createTopic from "./topic"

$(() => {
  $("[data-topic]").each((_index, el) => createTopic(socket, el))
})
