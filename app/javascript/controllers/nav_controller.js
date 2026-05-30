import { Controller } from "@hotwired/stimulus"

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
}
