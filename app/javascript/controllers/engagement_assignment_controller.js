import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["engagementBody"]

  collapse() {
    this.engagementBodyTarget.classList.add('u-none')
  }
}