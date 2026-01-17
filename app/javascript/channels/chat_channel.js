import { createConsumer } from "@rails/actioncable"

let consumer = null

function getConsumer() {
  if (!consumer) {
    const cableUrl = '/cable'
    consumer = createConsumer(cableUrl)
  }
  return consumer
}

export default class ChatChannel {
  constructor(messageThreadId, onMessageChunk, onMessageComplete, onMessageError) {
    this.messageThreadId = messageThreadId
    this.onMessageChunk = onMessageChunk
    this.onMessageComplete = onMessageComplete
    this.onMessageError = onMessageError
    this.subscription = null
  }

  connect() {
    const cableConsumer = getConsumer()
    this.subscription = cableConsumer.subscriptions.create(
      {
        channel: "ChatChannel",
        message_thread_id: this.messageThreadId
      },
      {
        connected: () => {
          console.log("ChatChannel connected")
        },
        disconnected: () => {
          console.log("ChatChannel disconnected")
        },
        received: (data) => {
          if (data.type === "message_chunk") {
            this.onMessageChunk(data.content)
          } else if (data.type === "message_complete") {
            this.onMessageComplete()
          } else if (data.type === "message_error") {
            this.onMessageError(data.error)
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

