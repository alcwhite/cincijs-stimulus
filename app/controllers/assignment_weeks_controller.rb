# frozen_string_literal: true

class AssignmentWeeksController < ApplicationController

  def copy_week
    # loop over weeks in chronological order
    while week <= ending_week
      manage_assignment_week(week)
      @week += 1.week
    end

    # render turbo stream to update assignment row without reloading page
    render turbo_stream: [turbo_stream.update("assignment-li-#{assignment.id}", partial: 'assignments/assignment',
                                                                                object: assignment)]
  end

  private

  def manage_assignment_week(week)
    # not a valid week, so skip it
    return false unless assignment.engagement.iteration?(week)

    # find current week
    assignment_week = AssignmentWeek.find_by(assignment: assignment, iteration: iteration(week), week: week)

    # non-existant week doesn't need to be deleted
    return true if max_billable_hours.zero? && assignment_week.blank?

    # update the week
    destroy_or_update assignment_week
  end

  def destroy_or_update(assignment_week)
    if max_billable_hours.zero?
      # delete weeks with hours set to 0
      assignment_week.destroy
    else
      # create week if it doesn't exist yet
      assignment_week ||= AssignmentWeek.create(assignment: assignment, iteration: iteration(week), week: week)
      #update week with new hours
      assignment_week.update(max_billable_hours: max_billable_hours)
    end
  end

  def assignment
    # set current assignment/row
    @assignment ||= Assignment.find(assignment_week_params[:assignment_id])
  end

  def source_week
    # find source (dragged) week
    @source_week ||= Date.parse(assignment_week_params[:source_week])
  end

  def destination_week
    # find destination (dropped) week
    @destination_week ||= Date.parse(assignment_week_params[:destination_week])
  end

  def week
    # current week -- start with chronologically earlier week
    # don't update source_week with its own data
    @week ||= source_week <= destination_week ? source_week +  : destination_week
  end

  def ending_week
    # chronologically latest week
    # don't update source_week with its own data
    @ending_week ||= source_week <= destination_week ? destination_week : source_week - 1.week
  end

  def max_billable_hours
    # hours for the source week -- what each week will update to
    @max_billable_hours ||= AssignmentWeek.find_by(assignment_id: assignment.id,
                                                   week: source_week)&.max_billable_hours || 0
  end

  def assignment_week_params
    # form params: assignment_week form with 3 fields (assignment_id, source_week, destination_week)
    params.require(:assignment_week).permit(:assignment_id, :source_week, :destination_week)
  end
end
