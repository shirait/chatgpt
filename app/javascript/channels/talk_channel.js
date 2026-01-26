import consumer from "channels/consumer"

export default class TalkChannel {
  constructor(talkThreadId, onMessage) {
    this.talkThreadId = talkThreadId
    this.onMessage = onMessage
    this.subscription = null
  }

  connect() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "TalkChannel",
        talk_thread_id: this.talkThreadId
      },
      {
        connected: () => {},
        disconnected: () => {},
        received: (data) => {
          if (data.type === "talk_message") {
            this.onMessage(data.message)
          }
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }
}
