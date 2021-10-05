import{ Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "assignmentId", "sourceWeek", "destinationWeek", "cell"]

  dragstart(event) {
    event.target.style.opacity = '0.4'
    this.assignmentId = this.assignmentIdTarget.value
    this.source_week = event.target.dataset['week'] || event.target.parentElement.dataset['week']
    this.destination_week = this.source_week
  }

  withinSelectedRange(cell) {
    return (Date.parse(cell.dataset["week"]) >= Date.parse(this.source_week) && 
              Date.parse(cell.dataset["week"]) <= Date.parse(this.destination_week)) 
            || (Date.parse(cell.dataset["week"]) <= Date.parse(this.source_week) && 
              Date.parse(cell.dataset["week"]) >= Date.parse(this.destination_week))
  }

  dragenter(event) {
    event.preventDefault();
    if (this.assignmentId === event.target.dataset['assignmentid']) {
      this.destination_week = event.target.dataset['week']
      this.cellTargets.forEach(cell => {
        if (this.withinSelectedRange(cell)) {
          cell.classList.add("timeline__selected")
        } else {
          cell.classList.remove("timeline__selected")
        }
      })
    }
  }
  
  dragend(event) {
    event.target.style.opacity = '1'
    event.target.classList.remove("timeline__selected")
    if (this.source_week !== this.destination_week) {
      this.sourceWeekTarget.value = this.source_week
      this.destinationWeekTarget.value = this.destination_week
      this.formTarget.requestSubmit()
    }
    
  }
}