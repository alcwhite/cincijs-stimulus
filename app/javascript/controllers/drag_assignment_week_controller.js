import{ Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "assignmentId", "sourceWeek", "destinationWeek", "cell"]
  static classes = ["selected", "dragging"]
  static values = {
    sourceWeek: String,
    destinationWeek: String,
    assignmentId: Number
  }

  get sourceWeekDate() { return Date.parse(this.sourceWeek) }
  get destinationWeekDate() { return Date.parse(this.destinationWeek) }

  dragstart(event) {
    event.target.classList.add(...this.draggingClasses)
    this.assignmentId = this.assignmentIdTarget.value
    this.sourceWeek = event.params.week
    this.destinationWeek = this.sourceWeek
  }

  withinSelectedRange(week) {
    const thisWeek = Date.parse(week)
    return (thisWeek >= this.sourceWeekDate && 
              thisWeek <= this.destinationWeekDate) 
            || (thisWeek <= this.sourceWeekDate && 
              thisWeek >= this.destinationWeekDate)
  }

  dragenter(event) {
    event.preventDefault();
    if (this.assignmentId == event.params.assignmentid) {
      this.destinationWeek = event.params.week
      this.cellTargets.forEach(cell => {
        if (this.withinSelectedRange(cell.dataset.dragAssignmentWeekWeekParam)) {
          cell.classList.add(this.selectedClass)
        } else {
          cell.classList.remove(this.selectedClass)
        }
      })
    }
  }
  
  dragend(event) {
    event.target.classList.remove(...this.draggingClasses)
    if (this.sourceWeek !== this.destinationWeek) {
      this.sourceWeekTarget.value = this.sourceWeek
      this.destinationWeekTarget.value = this.destinationWeek
      this.formTarget.requestSubmit()
    }
    
  }
}