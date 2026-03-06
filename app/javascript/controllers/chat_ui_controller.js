import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "sendButton", "messages", "typingIndicator"]
  static values = { maxRows: Number }

  connect() {
    this.updateComposer()
    this.scrollToBottom()
  }

  handleInput() {
    this.updateComposer()
  }

  handleSubmit(event) {
    const content = this.inputTarget.value.trim()

    if (content.length === 0) {
      event.preventDefault()
      this.inputTarget.value = ""
      this.updateComposer()
      return
    }

    this.sendButtonTarget.disabled = true
    this.formTarget.setAttribute("aria-busy", "true")
    this.showTypingIndicator()
    this.scrollToBottom()
  }

  updateComposer() {
    this.toggleSendButton()
    this.resizeInput()
  }

  toggleSendButton() {
    this.sendButtonTarget.disabled = this.inputTarget.value.trim().length === 0
  }

  resizeInput() {
    const maxRows = this.hasMaxRowsValue ? this.maxRowsValue : 3
    const style = window.getComputedStyle(this.inputTarget)
    const lineHeight = parseFloat(style.lineHeight) || 20
    const paddingTop = parseFloat(style.paddingTop) || 0
    const paddingBottom = parseFloat(style.paddingBottom) || 0
    const borderTop = parseFloat(style.borderTopWidth) || 0
    const borderBottom = parseFloat(style.borderBottomWidth) || 0
    const maxHeight = (lineHeight * maxRows) + paddingTop + paddingBottom + borderTop + borderBottom

    this.inputTarget.style.height = "auto"
    this.inputTarget.style.height = `${Math.min(this.inputTarget.scrollHeight, maxHeight)}px`
    this.inputTarget.style.overflowY = this.inputTarget.scrollHeight > maxHeight ? "auto" : "hidden"
  }

  showTypingIndicator() {
    if (!this.hasTypingIndicatorTarget) return
    this.typingIndicatorTarget.hidden = false
  }

  scrollToBottom() {
    if (!this.hasMessagesTarget) return

    requestAnimationFrame(() => {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    })
  }
}
