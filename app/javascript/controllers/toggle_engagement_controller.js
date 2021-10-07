import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["engagementBody", "button"]
  static classes = ["hide"]
  static values = {
    displayed: { type: Boolean, default: false },
    all: { type: Boolean, default: false },
  }

  get hiddenText() {
    return "Show"
  }
  get shownText() {
    return "Hide"
  }
  get allHiddenText() {
    return "Show all"
  }
  get allShownText() {
    return "Hide all"
  }
  get indButtons() {
    return this.application.controllers.filter(
      (c) => c.identifier === this.identifier && !c.allValue
    )
  }
  get groupButton() {
    return this.application.controllers.find(
      (c) => c.identifier === this.identifier && c.allValue
    )
  }

  toggle() {
    this.displayedValue ? this.hide() : this.show()

    this.allValue ? this.updateAllButtons() : this.updateGroupButton()
  }

  show() {
    this.displayedValue = true
    this.buttonTarget.innerText = this.allValue
      ? this.allShownText
      : this.shownText
    this.hasEngagementBodyTarget &&
      this.engagementBodyTarget.classList.remove(this.hideClass)
  }

  hide() {
    this.displayedValue = false
    this.buttonTarget.innerText = this.allValue
      ? this.allHiddenText
      : this.hiddenText
    this.hasEngagementBodyTarget &&
      this.engagementBodyTarget.classList.add(this.hideClass)
  }

  updateGroupButton() {
    this.indButtons.some((c) => !c.displayedValue)
      ? this.groupButton.hide()
      : this.groupButton.show()
  }

  updateAllButtons() {
    this.displayedValue
      ? this.indButtons.forEach((group) => {
          group.show()
        })
      : this.indButtons.forEach((group) => {
          group.hide()
        })
  }
}
