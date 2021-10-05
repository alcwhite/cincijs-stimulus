module AssignmentWeekHelper
  def data_attrs(assignment_week, assignment_id = nil, week = nil)
    assignment_week ||= AssignmentWeek.new(week: week, assignment_id: assignment_id)
    assignment_id_param = "data-drag-assignment-week-assignment-id-param=#{assignment_week.assignment_id}"
    week_param = "data-drag-assignment-week-week-param=#{assignment_week.week} data-week=#{assignment_week.week}"
    target = "data-drag-assignment-week-target=cell"
    "#{assignment_id_param} #{week_param} #{target} draggable=true"
  end
end
