module AssignmentWeekHelper
  # returns data attrs for an assignment week cell
  def data_attrs(assignment_week, assignment_id = nil, week = nil)
    # for empty cells, create new week
    assignment_week ||= AssignmentWeek.new(week: week, assignment_id: assignment_id)
    # sets assignment id to event params for row checks
    assignment_id_param = "data-drag-assignment-week-assignment-id-param=#{assignment_week.assignment_id}"
    # sets week to event params
    week_param = "data-drag-assignment-week-week-param=#{assignment_week.week}"
    # sets cell as a cellTarget on the row's controller
    target = "data-drag-assignment-week-target=cell"
    # draggable must be set to true (not a boolean attribute)
    "#{assignment_id_param} #{week_param} #{target} draggable=true"
  end

  # returns actions for an assignment week cell
  def action
    drag_start = "dragstart->drag-assignment-week#dragstart"
    drag_enter = "dragenter->drag-assignment-week#dragenter"
    drag_end = "dragend->drag-assignment-week#dragend"
    # when a drag-assignment-week controller sends out a hightlight event, call this
    highlight = "drag-assignment-week:highlight->drag-assignment-week#maybeHighlight"
    "#{drag_start} #{drag_enter} #{drag_end} #{highlight}"
  end
end
