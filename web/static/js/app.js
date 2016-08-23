import "phoenix_html"
import socket from "./socket"
import createTopic from "./topic"
import "./file_form"

$(() => {
  $("[data-topic]").each((_index, el) => createTopic(socket, el))
})
