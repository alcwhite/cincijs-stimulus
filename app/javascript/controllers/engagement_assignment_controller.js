import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["engagementBody"]
  static classes = ["hide"]

  collapse() {
    this.engagementBodyTarget.classList.add(this.hideClass)
  }
}