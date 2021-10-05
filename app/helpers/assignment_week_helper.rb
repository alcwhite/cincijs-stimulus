module AssignmentWeekHelper
  def data_attrs(assignment_week, assignment_id = nil, week = nil)
    assignment_week ||= AssignmentWeek.new(week: week, assignment_id: assignment_id)
    "data-drag-assignment-week-assignmentid-param=#{assignment_week.assignment_id} data-drag-assignment-week-week-param=#{assignment_week.week} data-drag-assignment-week-target=cell draggable=true"
  end
end
