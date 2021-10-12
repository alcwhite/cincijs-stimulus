import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // accessed via this.nameTarget or this.nameTargets
  static targets = ["engagementBody", "button"]
  // accessed via this.nameClass or ...this.nameClasses
  static classes = ["hide"]
  // accessed via this.nameValue (so for example, this.allValue)
  // defaults can be overridden in the template via data-toggle-engagement-{name}-value
  static values = {
    displayed: { type: Boolean, default: false },
    all: { type: Boolean, default: false },
  }

  // return some text defaults
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

  // filters all instantiated controllers to return an array of all individual toggle button controllers
  // identifier is the name of the controller as used in the template
  get indButtons() {
    return this.application.controllers.filter(
      (c) => c.identifier === this.identifier && !c.allValue
    )
  }
  // filters all instantiated controllers to return the group toggle button controller
  // identifier is the name of the controller as used in the template
  get groupButton() {
    return this.application.controllers.find(
      (c) => c.identifier === this.identifier && c.allValue
    )
  }

  // toggles the element
  toggle() {
    // if displayed, hide, else show
    this.displayedValue ? this.hide() : this.show()

    // if this is a group button, update all buttons, else update group button
    this.allValue ? this.updateAllButtons() : this.updateGroupButton()
  }

  // internal: shows element
  _show() {
    // set displayed to true
    this.displayedValue = true
    // change text on button
    this.buttonTarget.innerText = this.allValue
      ? this.allShownText
      : this.shownText
    // if engagement body target exists, show it
    this.hasEngagementBodyTarget &&
      this.engagementBodyTarget.classList.remove(this.hideClass)
  }

  // internal: hides element
  _hide() {
    // set displayed to false
    this.displayedValue = false
    // change text on button
    this.buttonTarget.innerText = this.allValue
      ? this.allHiddenText
      : this.hiddenText
    // if engagement body target exists, hide it
    this.hasEngagementBodyTarget &&
      this.engagementBodyTarget.classList.add(this.hideClass)
  }

  // internal: updates the toggle all button
  _updateGroupButton() {
    this.indButtons.some((c) => !c.displayedValue)
      ? this.groupButton._hide()
      : this.groupButton._show()
  }

  // internal: iterates through and updates all individual toggle sections
  _updateAllButtons() {
    this.displayedValue
      ? this.indButtons.forEach((body) => {
          body._show()
        })
      : this.indButtons.forEach((body) => {
          body._hide()
        })
  }
}
