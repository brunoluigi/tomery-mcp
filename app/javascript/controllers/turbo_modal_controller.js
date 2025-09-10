import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbo-modal"
export default class extends Controller {
  connect() {
    this.element.focus()
  }

  hideModal() {
    this.element.remove()
  }
}
