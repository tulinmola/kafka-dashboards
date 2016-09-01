import socket from "./socket"

$(() => {
  $("[data-topic]").each((_index, el) => createTopic(socket, el))
})

function createTopic(socket, el) {
  const $el = $(el),
        $messages = $el.find(".messages"),
        name = $el.data("topic"),
        channel = socket.channel(`topic:${name}`, {})

  // Join to topic channel
  channel.join()
    .receive("ok", ({messages}) => addMessages($messages, messages))
    .receive("error", resp => { console.log("Unable to join", resp) })

  // And listen for messages for that topic
  channel.on("message", ({offset, value}) => addMessage($messages, value))
}

function addMessages($el, messages) {
  for (let message of messages) {
    addMessage($el, message)
  }
}

function addMessage($el, message) {
  const $item = $("<li>").html(message)
  $el.prepend($item)
}
