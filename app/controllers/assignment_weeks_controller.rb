# frozen_string_literal: true

class AssignmentWeeksController < ApplicationController
  before_action :set_assignment_week, only: %i[edit show update]

  def index
    start_date = params.fetch(:week, 30.days.ago).to_date.beginning_of_week
    assignment_weeks = AssignmentWeek.starting_on(start_date)
    respond_with assignment_weeks
  end

  def new
    @assignment_week = AssignmentWeek.new(assignment_id: params[:assignment_id], iteration_id: iteration.id,
                                          week: iteration.week)
  end

  def create
    @assignment_week = AssignmentWeek.new(new_assignment_week_params)
    if @assignment_week.save
      redirect_to @assignment_week
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    @new_assignment_week = @assignment_week.clone
    if manage_assignment_week(@assignment_week.week)
      render_empty_cell_or_redirect
    else
      Rails.logger.debug(
        "Error saving assignment week #{@assignment_week.id}: #{@assignment_week.errors.full_messages.to_sentence}"
      )
      render 'edit', status: :unprocessable_entity
    end
  end

  def copy_week
    while week <= ending_week
      manage_assignment_week(week)
      @week += 7.days
    end

    render turbo_stream: [turbo_stream.update("assignment-li-#{assignment.id}", partial: 'assignments/assignment',
                                                                                object: assignment)]
  end

  private

  def manage_assignment_week(week)
    return false unless assignment.engagement.iteration?(week)

    assignment_week = AssignmentWeek.find_by(assignment: assignment, iteration: iteration(week), week: week)

    return true if max_billable_hours.zero? && assignment_week.blank?

    destroy_or_update assignment_week
  end

  def destroy_or_update(assignment_week)
    if max_billable_hours.zero? && assignment_week&.time_entries.blank?
      assignment_week.destroy
    else
      assignment_week ||= AssignmentWeek.create(assignment: assignment, iteration: iteration(week), week: week)
      assignment_week.update(max_billable_hours: max_billable_hours)
    end
  end

  def assignment
    @assignment ||= Assignment.find(params[:assignment_id] || params[:assignment_week][:assignment_id])
  end

  def iteration(week = nil)
    assignment.engagement.iteration_on(week || Date.parse(params[:week] || params[:assignment_week][:week]))
  end

  def source_week
    @source_week ||= Date.parse(params[:assignment_week][:source_week] || params[:assignment_week][:week])
  end

  def destination_week
    @destination_week ||= Date.parse(params[:assignment_week][:destination_week] || params[:assignment_week][:week])
  end

  def week
    @week ||= source_week <= destination_week ? source_week + 7.days : destination_week
  end

  def ending_week
    @ending_week ||= source_week <= destination_week ? destination_week : source_week - 7.days
  end

  def max_billable_hours
    if params[:assignment_week][:max_billable_hours].present?
      @max_billable_hours ||= params[:assignment_week][:max_billable_hours].to_f
    end
    @max_billable_hours ||= AssignmentWeek.find_by(assignment_id: assignment.id,
                                                   week: source_week)&.max_billable_hours || 0
  end

  def assignment_week_params_old
    params.permit(:id, :week, :engagement_id, :person_id, assignment_week: %i[person_id week max_billable_hours])
  end

  def new_assignment_week_params
    params.require(:assignment_week).permit(:assignment_id, :iteration_id, :week, :max_billable_hours)
  end

  def assignment_week_params
    params.require(:assignment_week).permit(:max_billable_hours, :assignment_id, :week)
  end

  def set_assignment_week
    @assignment_week = AssignmentWeek.find_by(id: params[:id])
  end
end
