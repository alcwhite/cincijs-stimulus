# frozen_string_literal: true

class Engagement < ApplicationRecord
  has_many :iterations, -> { order("#{Iteration.table_name}.week desc") }, dependent: :destroy
  has_many :assignments
  has_many :assignment_weeks, through: :iterations
  has_many :all_people, lambda {
                          order(name: :asc).distinct
                        }, class_name: 'Person', through: :assignments, foreign_key: :person_id, source: :person
  has_many :time_entries, through: :assignment_weeks, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :starts_on, :ends_on, presence: true
  validate :ends_after_it_begins?

  after_update :remove_invalid_iterations

  scope :recent, -> { where('engagements.ends_on >= ?', 1.month.ago) }

  def self.preload_tree
    preload(all_people: [
              assignment_weeks: [:time_entries]
            ],
            iterations: [
              :time_entries,
              :engagement,
                assignment_weeks: [assignment: :person]
            ])
  end

  def self.upcoming
    where('engagements.starts_on >= ?', Time.zone.today)
  end

  def self.starting_week_of(date = Time.zone.today)
    start_date = date.beginning_of_week
    end_date = start_date + 6.days
    where('engagements.starts_on >= ? AND engagements.starts_on <= ?', start_date, end_date)
  end

  def self.ending_week_of(date = Time.zone.today)
    start_date = date.beginning_of_week
    end_date = start_date + 6.days
    where('engagements.ends_on >= ? AND engagements.ends_on <= ?', start_date, end_date)
  end

  def self.current
    today = Time.zone.today
    where('engagements.starts_on <= ? and engagements.ends_on >= ?', today, today).order('starts_on DESC')
  end

  def self.prior
    where('engagements.ends_on <= ?', Time.zone.today)
  end

  def self.active(date = Time.zone.today)
    active_on(date)
  end

  def self.active_within(start_date, end_date)
    where('(starts_on <= :start_date AND :start_date <= ends_on) OR
           (:start_date <= starts_on AND starts_on <= :end_date) OR
           (:start_date <= ends_on AND ends_on <= :end_date)',
          start_date: start_date, end_date: end_date)
  end

  def self.active_on(date)
    where('(:date BETWEEN starts_on AND ends_on)', date: date)
  end

  def active_on(date)
    return false if starts_on.nil? || ends_on.nil?

    starts_on <= date && date <= ends_on
  end

  def unassign(assignment)
    assignment.assignment_weeks.reject { |aw| aw.time_entries.any? }.map(&:destroy)
    assignment.destroy if assignment.assignment_weeks.all?(&:destroyed?)
  end

  def assignments_within(start_date, end_date)
    assignments.select { |a| a.week >= start_date && a.week <= end_date }
  end

  def remove_invalid_iterations
    iterations.where(['week > ?', ends_on]).map(&:destroy) if saved_change_to_ends_on? && ends_on.present?
    iterations.where(['week < ?', starts_on]).map(&:destroy) if saved_change_to_starts_on?
  end

  def current_iteration
    return unless current?

    week = Time.zone.today.beginning_of_week(:monday)
    iteration_on(week)
  end

  def iteration?(date)
    starts_on.present? && ends_on.present? && starts_on <= date && ends_on >= date
  end

  def iteration_on(date, params = {})
    return unless iteration?(date)

    week_start = date.beginning_of_week(:monday)
    new_params = params.merge(week: week_start, engagement: self)
    # check for the desired iteration from memory first. there's a lot of
    # reporting that uses eager loading of iterations and we want to avoid
    # hitting the database again
    iteration = iterations.detect { |i| i.week == week_start }
    # If there's no iteration loaded in memory, try to create one
    iteration ||= Iteration.create(new_params)
    return iteration unless iteration.errors.any? && !iteration.valid?

    # If the created iteration is invalid, assume it's because it's a
    # duplicate and refetch the desired iteration from the database
    iterations.where(week: week_start).first
  end

  def duration
    ((ends_on || Time.zone.today) - starts_on).to_f
  end

  def current?
    starts_on <= Time.zone.today && ends_on >= Time.zone.today
  end

  def prior?
    starts_on < Time.zone.today && ends_on && ends_on < Time.zone.today
  end

  def upcoming?
    starts_on > Time.zone.today && ends_on > Time.zone.today
  end

  def people
    current_iteration.assignment_weeks.collect(&:person)
  end

  def self.projects(week)
    active_on(week).order('ends_on DESC')
  end

  def self.assignment_week_ids(engagement_id)
    find(engagement_id).assignment_weeks.pluck(:id)
  end

  def assignment_blocks
    AssignmentBlock.from_engagement_assignment_weeks(self)
  end

  def display_starts_on
    display_date(starts_on)
  end

  def display_ends_on
    display_date(ends_on)
  end

  private

  def display_date(date)
    date.try(:strftime, '%m/%d') || 'N/A'
  end

  def starts_in_the_future?
    starts_on.present? && starts_on >= Time.zone.today
  end

  def ends_after_it_begins?
    errors.add(:ends_on, 'must end after it begins') if ends_on.present? && starts_on.present? && ends_on < starts_on
  end
end
