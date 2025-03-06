import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.startAutoDismiss()
  }

  startAutoDismiss() {
    setTimeout(() => {
      this.dismiss()
    }, 5000) // Auto-hide after 5 seconds
  }

  dismiss() {
    this.element.classList.add("opacity-0") // Start fade-out effect
    setTimeout(() => this.element.remove(), 500) // Remove after transition
  }
}
