import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbo-modal"
export default class extends Controller {
  connect() {
    this.element.focus()
    console.debug("Modal Controller connected")
    
    this.boundHandleKeydown = this.handleKeydown.bind(this)

    this.element.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    console.debug("Modal Controller disconnected")
    this.element.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    console.debug("Modal Controller handleKeydown")

    event.stopPropagation()
  }

  hideModal() {
    this.element.remove()
  }
}
