import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["engagementBody"]

  toggle(event) {
    event.target.innerText = event.target.innerText == "Show" ? "Hide" : "Show"
    event.target.getAttribute("data-display") === "hidden" ? event.target.setAttribute("data-display", "shown") : event.target.setAttribute("data-display", "hidden")

    this.engagementBodyTarget.classList.toggle("u-none")
    const groupButton = document.querySelector(".toggle-button__group")

    if (Array.from(document.querySelectorAll(".toggle-button__ind")).some(button => button.getAttribute("data-display") === "hidden")) {
      groupButton.innerText = "Show All"
      groupButton.setAttribute("data-display", "hidden")
    } else {
      groupButton.innerText = "Hide All"
      groupButton.setAttribute("data-display", "shown")
    }
  }
}