import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // accessed via this.nameTarget or this.nameTargets
  // this.cellTarget would return the first cell in the row
  // this.cellTargets would return all cells in the row
  static targets = [
    "form",
    "sourceWeek",
    "destinationWeek",
    "cell",
  ]
  // accessed via this.nameClass or ...this.nameClasses
  static classes = ["selected", "opacity"]
  // accessed via this.dragStartedValue
  // defaults are optional and can be overridden in the template with "data-#{identifier}-#{valueName}"
  static values = {
    dragStarted: {type: Boolean, default: false}
  }

  // this will return parsed sourceWeek once it's set--or NaN
  get sourceWeekDate() {
    return Date.parse(this.sourceWeek)
  }
  // this will return parsed destinationWeek once it's set--or NaN
  get destinationWeekDate() {
    return Date.parse(this.destinationWeek)
  }

  // called on dragstart event
  // event contains target (the cell being dragged) and params (set in template: {week: week})
  dragstart(event) {
    // give source cell an opacity class to set it apart
    event.target.classList.add(this.opacityClass)
    // set sourceWeek on this controller
    this.sourceWeek = event.params.week
    // initially set destinationWeek to be same as sourceWeek
    this.destinationWeek = this.sourceWeek
    this.dragStartedValue = true
  }

  // internal helper function
  // checks if the current week is between source and destination week
  _withinSelectedRange(week) {
    const thisWeek = Date.parse(week)
    return (
      (thisWeek >= this.sourceWeekDate &&
        thisWeek <= this.destinationWeekDate) ||
      (thisWeek <= this.sourceWeekDate && thisWeek >= this.destinationWeekDate)
    )
  }

  // called on dragenter event
  // event contains target (the cell being dragged) and params (set in template: {week: week})
  dragenter(event) {
    event.preventDefault()
    // check that we're on the same row, since each row will be able to call dragenter
    if (this.dragStartedValue) {
      // sets destination week
      this.destinationWeek = event.params.week
      this.cellTargets.forEach((cell) => {
        this._maybeHighlight(cell)
      })
    }
  }

  // called on dragend event
  // event contains target (the cell being dragged) and params (set in template: {week: week})
  dragend(event) {
    // removes selected/dragging classes from initial dragging target
    event.target.classList.remove(this.opacityClass, this.selectedClass)
    this.dragStartedValue = false
    // don't submit form when dropping a cell on itself 
    if (this.sourceWeek !== this.destinationWeek) {
      // set source and destination weeks on the form
      this.sourceWeekTarget.value = this.sourceWeek
      this.destinationWeekTarget.value = this.destinationWeek
      // submit form
      // turbo requires use of requestSubmit() instead of just submit()
      this.formTarget.requestSubmit()
    }
  }

  // internal: checks whether or not to highlight a cell
  _maybeHighlight(cell) {
    if (this._withinSelectedRange(cell.dataset.week)) {
      cell.classList.add(this.selectedClass)
    } else {
      cell.classList.remove(this.selectedClass)
    }
  }
}
