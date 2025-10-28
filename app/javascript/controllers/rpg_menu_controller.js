import { Controller } from "@hotwired/stimulus"

// RPG-style menu with keyboard navigation
export default class extends Controller {
  static targets = ["item"]
  static values = { selected: Number }

  connect() {
    // Focus on first item when menu loads
    this.selectItem(this.selectedValue)
    
    // Listen for keyboard events on the window
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    // Only handle arrow keys and Enter when menu is visible
    if (!this.element.offsetParent) return

    switch(event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.moveDown()
        break
      case "ArrowUp":
        event.preventDefault()
        this.moveUp()
        break
      case "Enter":
        event.preventDefault()
        this.activateSelected()
        break
    }
  }

  moveDown() {
    const nextIndex = (this.selectedValue + 1) % this.itemTargets.length
    this.selectItem(nextIndex)
  }

  moveUp() {
    const prevIndex = (this.selectedValue - 1 + this.itemTargets.length) % this.itemTargets.length
    this.selectItem(prevIndex)
  }

  selectItem(index) {
    this.selectedValue = index
    
    // Remove selection from all items
    this.itemTargets.forEach(item => {
      item.classList.remove("border-[rgba(0,255,128,0.8)]", "shadow-[0_0_30px_rgba(0,255,128,0.3)]")
      item.classList.add("border-[rgba(0,255,128,0.25)]")
      item.blur() // Remove focus to prevent blue outline
    })
    
    // Highlight the selected item (without focusing to avoid blue outline)
    const selectedItem = this.itemTargets[index]
    if (selectedItem) {
      selectedItem.classList.remove("border-[rgba(0,255,128,0.25)]")
      selectedItem.classList.add("border-[rgba(0,255,128,0.8)]", "shadow-[0_0_30px_rgba(0,255,128,0.3)]")
    }
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.selectItem(index)
  }

  activateSelected() {
    const selectedItem = this.itemTargets[this.selectedValue]
    if (selectedItem) {
      // Click the link to let Turbo handle navigation naturally
      // This will update the URL and use the turbo-frame attribute
      selectedItem.click()
    }
  }
}
