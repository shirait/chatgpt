import consumer from "channels/consumer"

consumer.subscriptions.create("ChatChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  }
});

const log = (s) => {
  const el = document.getElementById("log")
  el.textContent += s + "\n"
}

const channel = consumer.subscriptions.create("ChatChannel", {
  received(data) {
    log("received: " + JSON.stringify(data))
  }
})

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("send").addEventListener("click", async () => {
    const msg = document.getElementById("msg").value
    // 送信はHTTPでブロードキャストするのが簡単（後述）
    await fetch("/broadcast?msg=" + encodeURIComponent(msg))
  })
})
