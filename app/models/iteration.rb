# frozen_string_literal: true

class Iteration < ApplicationRecord
  belongs_to :engagement

  has_many :assignment_weeks, dependent: :destroy
  has_many :time_entries, through: :assignment_weeks

  validates :week, uniqueness: { scope: :engagement_id, message: 'should only have one iteration per engagement week' }

  def self.previous
    where('iterations.week <= ?', Time.zone.today.beginning_of_week(:monday))
  end

  def self.current
    where('iterations.week = ?', Time.zone.today.beginning_of_week(:monday))
  end

  def create_assignment_week(attributes = {})
    person = attributes.delete(:person)
    assignment_attributes = {
      person: person,
      engagement: self.engagement,
    }
    assignment = Assignment.find_or_create_by(assignment_attributes)
    Rails.logger.debug("assignment: #{assignment.errors.inspect}")
    attributes = attributes.merge(week: week, iteration: self, assignment: assignment)
    assignment_weeks.create(attributes)
  end

  def assign(attributes = {})
    assignment_week = assignment_weeks.detect { |a| a.person_id.nil? }
    if attributes[:person]
      assignment_week.update(person: attributes[:person])
    else
      assignment_week.update(person_id: attributes[:person_id])
    end
  end

  def max_billable_hours
    @max_billable_hours ||= assignment_weeks.map(&:max_billable_hours).sum
  end

  def has_assignment_weeks?
    @has_assignment_weeks ||= assignment_weeks.reject(&:unassigned?).count > 0
  end

  def current?
    @this_monday ||= Time.zone.today.beginning_of_week
    week == @this_monday ? "current-week" : ""
  end

  def for_year?(year = nil)
    return true if year.blank?
    
    year = year.respond_to?(:year) ? year.year : year.to_i
    week.year == year
  end

  private

  def sunday
    @sunday ||= week - week.wday
  end

  def saturday
    sunday + 7
  end

  def engagement_name
    engagement.name
  end
end
