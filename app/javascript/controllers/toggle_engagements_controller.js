import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["engagementBody"]
  
  toggleAll(event) {
    if (event.target.getAttribute("data-display") === "hidden") {
      event.target.innerText = "Hide All"
      event.target.setAttribute("data-display", "shown")
      this.engagementBodyTargets.forEach(group => {
        group.classList.remove("u-none")
        const button = group.parentElement.querySelector(".toggle-button__ind")
        button.innerText = "Hide"
        button.setAttribute("data-display", "shown")
      })
    } else {
      event.target.innerText = "Show All"
      event.target.setAttribute("data-display", "hidden")
      this.engagementBodyTargets.forEach(group => {
        group.classList.add("u-none")
        const button = group.parentElement.querySelector(".toggle-button__ind")
        button.innerText = "Show"
        button.setAttribute('data-display', "hidden")
      })
    }
  }
}