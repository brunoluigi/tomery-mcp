import { Controller } from "@hotwired/stimulus"

// RPG-style menu with keyboard navigation
export default class extends Controller {
  static targets = ["item"]
  static values = { selected: Number }

  connect() {
    console.debug("RPG Menu Controller connected")

    this.selectItem(this.selectedValue || 0)
    
    this.boundHandleKeydown = this.handleKeydown.bind(this)

    window.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    console.debug("RPG Menu Controller disconnected")
    window.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    console.debug("RPG Menu Controller handleKeydown")
  
    if (!this.element.offsetParent) return;

    switch(event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectItem(this.selectedValue + 1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectItem(this.selectedValue - 1)
        break
      case "Enter":
        event.preventDefault()
        this.activateSelected()
        break
    }
  }

  selectItem(index) {
    console.debug("RPG Menu Controller selectItem", index)

    let newIndex = index;
    const length = this.itemTargets.length

    if(newIndex < 0) {
      newIndex = length - 1
    } else if(newIndex >= length) {
      newIndex = 0
    }

    this.selectedValue = newIndex
    
    const selectedItem = this.itemTargets[newIndex]
    if (selectedItem) {
      selectedItem.focus();
    }
  }

  activateSelected() {
    const selectedItem = this.itemTargets[this.selectedValue]

    if (selectedItem) {
      selectedItem.click()
    }
  }
}
