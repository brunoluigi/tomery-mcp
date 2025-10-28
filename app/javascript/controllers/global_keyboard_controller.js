import { Controller } from "@hotwired/stimulus"

// Global keyboard shortcuts that work everywhere
export default class extends Controller {
  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    // Escape key - go back to menu
    if (event.key === "Escape") {
      const backLink = document.querySelector('a[href="/"]')
      if (backLink && backLink.textContent.includes('Back to menu')) {
        event.preventDefault()
        backLink.click()
      }
    }
  }
}
