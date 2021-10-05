# frozen_string_literal: true

class SchedulesController < ApplicationController
  before_action :set_assignment, only: %i[assignment_edit assignment_update]
  before_action :set_engagement, only: %i[engagement_edit engagement_update engagement_show]

  helper ScheduleGridHelper

  def show
    @engagements = Engagement.preload_tree.active_within(helpers.start_date, helpers.end_date)
  end

  def engagement_update
    if safe_to_change_dates?(params['engagement']['starts_on'],
                             params['engagement']['ends_on']) && @engagement.update(engagement_params)                     
      render turbo_stream: [turbo_stream.update("engagement-ul-#{@engagement.id}", partial: 'engagement',
                                                                                   locals: { engagement: @engagement })]
    else
      Rails.logger.debug("Error saving engagement #{@engagement.id}: #{@engagement.errors.full_messages.to_sentence}")
      render 'engagement_edit', status: :unprocessable_entity, locals: { engagement: @engagement }
    end
  end

  private

  def safe_to_change_dates?(new_starts_on, new_ends_on)
    return false if new_starts_on.nil? || new_ends_on.nil?

    free_of_time_entries?(new_ends_on, new_starts_on)
  end

  def free_of_time_entries?(ends_on, starts_on)
    return true if ends_on.blank?

    extra_iterations = @engagement.iterations.where(['week > ? OR week < ? ', ends_on, starts_on])
    extra_iterations.each do |iteration|
      return false if iteration&.assignment_weeks&.select(&:has_time_entries?)&.count.to_i.positive?
    end

    true
  end

  def set_assignment
    @assignment = Assignment.find_by(id: params[:id])
  end

  def set_engagement
    @engagement = Engagement.find_by(id: params[:id])
  end
end
