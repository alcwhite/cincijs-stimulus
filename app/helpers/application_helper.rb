module ApplicationHelper
  def assignment_week_dom_id(assignment_week)
    "assignment-week-#{assignment_week.assignment_id}-#{assignment_week.week}"
  end

  def assignment_dom_id(assignment)
    "assignment-#{assignment.engagement_id}"
  end
end
