# frozen_string_literal: true

class AssignmentWeek < ApplicationRecord
  belongs_to :assignment, autosave: true, inverse_of: :assignment_weeks
  belongs_to :iteration
  has_many :time_entries, dependent: :restrict_with_exception

  validates :week, presence: true

  delegate :engagement, :engagement_id, to: :iteration, allow_nil: true

  before_save { assignment.try(:save) }
  before_validation { assignment.valid? }

  def <=>(b)
    [person_name, max_billable_hours, week] <=>
      [b.person_name, max_billable_hours, b.week]
  end

  def self.current
    where(week: Time.zone.today.beginning_of_week)
  end

  def self.starting_on(monday)
    where('week >= ?', monday)
      .includes(:iteration, :engagement, :person)
      .order(:week)
  end

  def self.assignment_weeks_without_time_sheets(week)
    people_assigned = AssignmentWeek.includes(assignment: [:person]).where(week: week).collect(&:person).reject(&:nil?)
    people_with_timesheets = TimeSheet.includes(:person).where(start_date: week).collect(&:person)
    people_missing_timesheets = (people_assigned - people_with_timesheets)
    people_missing_timesheets.each { |p| TimeSheet.create_for_pto(p, week, week+4) }
    people_with_timesheets = TimeSheet.includes(:person).where(start_date: week).collect(&:person)
    people_missing_timesheets = (people_assigned - people_with_timesheets)
  end

  def self.people_without_time_sheets(start_date, end_date)
    start_date = start_date.beginning_of_week
    end_date = end_date.beginning_of_week
    mondays = (start_date..end_date).select(&:monday?)
    people = mondays.map { |m| assignment_weeks_without_time_sheets(m) }
    people.flatten!.uniq! unless people.empty?
    people
  end

  def self.from_weeks(engagement, weeks, person, max_billable_hours = 40)
    assignment_weeks = weeks.collect do |week|
      iteration = engagement.iteration_on(week)
      assignment_attributes = {engagement: engagement}
      assignment = Assignment.find_or_create_by(assignment_attributes)
      assignment_week = AssignmentWeek.find_or_initialize_by(assignment: assignment, iteration: iteration, week: week)
      assignment_week.max_billable_hours = max_billable_hours
      assignment_week
    end
    assignment_weeks
  end

  def self.new_need_from_weeks(engagement, weeks, max_billable_hours = 40)
    assignment_attributes = {engagement: engagement}
    assignment = Assignment.find_or_create_by(assignment_attributes)
    assignment_weeks = weeks.collect do |week|
      iteration = engagement.iteration_on(week)
      AssignmentWeek.new(iteration: iteration, week: week, assignment: assignment, max_billable_hours: max_billable_hours)
    end
    assignment_weeks
  end

  def person_name
    person.try(:name) || "NAME"
  end

  def person
    @person ||= assignment.person
    @person ||= time_entries.first.try(:person)
  end

  def person_week(_week = nil)
    @person_week ||= person.try(:person_week, week)
  end

  def missing_hours
    person_week.try(:missing_hours) || 0
  end

  def as_json(options = {})
    super(options.merge(methods: %i[engagement_id errors]))
  end

  def has_time_entries?
    time_entries.size > 0
  end

  def time_sheet
    time_entries.first.time_sheet if has_time_entries?
  end

  def unassigned?
    person.nil?
  end

  def in_the_past?
    week < Time.zone.today.beginning_of_week
  end

  private
  def week_days
    (week..(week + 4.days))
  end
end
