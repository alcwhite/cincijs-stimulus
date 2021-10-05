import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["engagementBody"]
  static classes = ["hide"]
  static values = {
    displayed: { type: Boolean, default: false },
    all: { type: Boolean, default: false }
  }

  get hiddenText() { return "Show" }
  get shownText() { return "Hide" }
  get allHiddenText() { return "Show all" }
  get allShownText() { return "Hide all" }
  get displayHiddenText() { return "hidden" }
  get displayShownText() { return "shown" }
  get displayAttrName() { return "data-display" }
  get toggleButtonGroupClass() { return ".toggle-button__group" }
  get groupButton() { return document.querySelector(this.toggleButtonGroupClass) }

  toggle(event) {
    if (this.displayedValue) {
      this.displayedValue = false
      event.target.innerText = this.hiddenText
      event.target.setAttribute(this.displayAttrName, this.displayHiddenText)
    } else {
      this.displayedValue = true
      event.target.innerText = this.shownText
      event.target.setAttribute(this.displayAttrName, this.displayShownText)
    }

    this.engagementBodyTarget.classList.toggle(this.hideClass)
    if (this.application.controllers.filter(c => c.identifier === this.identifier).some(c => !c.displayedValue)) {
      this.groupButton.innerText = this.allHiddenText
      this.groupButton.setAttribute(this.displayAttrName, this.displayHiddenText)
    } else {
      this.groupButton.innerText = this.allShownText
      this.groupButton.setAttribute(this.displayAttrName, this.displayShownText)
    }
  }
}