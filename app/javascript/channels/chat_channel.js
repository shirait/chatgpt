import { createConsumer } from "@rails/actioncable"

// ActionCableのURL。基本的に /cable とする。
const cableUrl = '/cable'
const cableConsumer = createConsumer(cableUrl)

// チャネルクラス。ActionCableのコンシューマーに接続するために必要なクラス。
export default class ChatChannel {
  // ChatChannelのインスタンスを作成する。
  constructor(messageThreadId, onMessageChunk, onMessageComplete, onMessageError) {
    this.messageThreadId = messageThreadId
    this.onMessageChunk = onMessageChunk
    this.onMessageComplete = onMessageComplete
    this.onMessageError = onMessageError
    this.subscription = null
  }

  // ChatChannelのインスタンスメソッド。
  // WebSocketの購読（subscription）を作成する。
  connect() {
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
            this.onMessageChunk(data.content, data.index)
          } else if (data.type === "message_complete") {
            this.onMessageComplete()
          } else if (data.type === "message_error") {
            this.onMessageError(data.error)
          }
        }
      }
    )
  }

  // ChatChannelのインスタンスメソッド。
  // WebSocketの購読（subscription）を解除する。
  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }
}

