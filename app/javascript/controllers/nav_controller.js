import { Controller } from "@hotwired/stimulus"

const DESKTOP_QUERY = "(min-width: 769px)"

export default class extends Controller {
  static targets = [ "menu", "toggle" ]

  toggle() {
    const open = this.menuTarget.classList.toggle("is-open")
    this.toggleTarget.setAttribute("aria-expanded", open)
  }

  close() {
    this.menuTarget.classList.remove("is-open")
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  closeOnDesktop() {
    if (window.matchMedia(DESKTOP_QUERY).matches) this.close()
  }
}
