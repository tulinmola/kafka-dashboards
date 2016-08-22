function addMessage($el, message) {
  const $item = $("<li>").html(message)
  $el.prepend($item)
}

function addMessages($el, messages) {
  for (let message of messages) {
    addMessage($el, message)
  }
}

export default function(socket, el) {
  const $el = $(el),
        name = $el.data("topic"),
        channel = socket.channel(`topic:${name}`, {})

  // Join to topic channel
  channel.join()
    .receive("ok", ({messages}) => addMessages($el, messages))
    .receive("error", resp => { console.log("Unable to join", resp) })

  // And listen for messages for that topic
  channel.on("message", ({offset, value}) => addMessage($el, value))
}
