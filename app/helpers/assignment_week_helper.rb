module AssignmentWeekHelper
  # returns data attrs for an assignment week cell
  def data_attrs(assignment_week, assignment_id = nil, week = nil)
    # for empty cells, create new week
    assignment_week ||= AssignmentWeek.new(week: week, assignment_id: assignment_id)
    # sets week to event params
    week_param = "data-drag-assignment-week-week-param=#{assignment_week.week}"
    # sets cell as a cellTarget on the row's controller
    target = "data-drag-assignment-week-target=cell"
    # sets week to dataset
    week = "data-week=#{assignment_week.week}"
    # draggable must be set to true (not a boolean attribute)
    "#{week_param} #{target} #{week} draggable=true"
  end

  # returns actions for an assignment week cell
  def action
    drag_start = "dragstart->drag-assignment-week#dragstart"
    drag_enter = "dragenter->drag-assignment-week#dragenter"
    drag_end = "dragend->drag-assignment-week#dragend"
    "#{drag_start} #{drag_enter} #{drag_end}"
  end
end
